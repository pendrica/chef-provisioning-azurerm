require 'chef/provisioning/azurerm/azure_provider'

class Chef
  class Provider
    class AzureResourceTemplate < Chef::Provisioning::AzureRM::AzureProvider
      provides :azure_resource_template

      def whyrun_supported?
        true
      end

      action :deploy do
        converge_by("deploy or re-deploy Resource Manager template '#{new_resource.name}'") do
          result = resource_management_client.deployments.create_or_update(new_resource.resource_group, new_resource.name, deployment).value!
          action_handler.report_progress "Result: #{result.body.properties.provisioning_state}"
          Chef::Log.debug("result: #{result.body.inspect}")
          follow_deployment_until_end_state
        end
      end

      def deployment
        deployment = Azure::ARM::Resources::Models::Deployment.new
        deployment.properties = Azure::ARM::Resources::Models::DeploymentProperties.new
        deployment.properties.template = template
        deployment.properties.mode = Azure::ARM::Resources::Models::DeploymentMode::Incremental
        deployment.properties.parameters = parameters_in_values_format
        deployment
      end

      def template
        template_src_file = ::File.join(Chef::Config[:chef_repo_path], new_resource.template_source)
        fail "Cannot find file: #{template_src_file}" unless ::File.file?(template_src_file)
        template = JSON.parse(::IO.read(template_src_file))
        if new_resource.chef_extension
          machines = template['resources'].select { |h| h['type'] == 'Microsoft.Compute/virtualMachines' }
          machines.each do |machine|
            action_handler.report_progress "adding a Chef VM Extension with name: #{machine['name']} and location: #{machine['location']} "
            extension = chef_vm_extension(machine['name'], machine['location'])
            template['resources'] << JSON.parse(extension)
          end
        end
        template
      end

      def parameters_in_values_format
        parameters = new_resource.parameters.map do |key, value|
          { key.to_sym => { 'value' => value } }
        end
        parameters.reduce(:merge!)
      end

      def chef_vm_extension(machine_name, location)
        chef_server_url = Chef::Config[:chef_server_url]
        validation_client_name = Chef::Config[:validation_client_name]
        validation_key_content = ::File.read(Chef::Config[:validation_key])
        <<-EOH
          {
            "type": "Microsoft.Compute/virtualMachines/extensions",
            "name": "[concat(#{machine_name.delete('[]')},'/', 'chefExtension')]",
            "apiVersion": "2015-05-01-preview",
            "location": "#{location}",
            "dependsOn": [
              "[concat('Microsoft.Compute/virtualMachines/', #{machine_name.delete('[]')})]"
            ],
            "properties": {
              "publisher": "Chef.Bootstrap.WindowsAzure",
              "type": "#{new_resource.chef_extension[:client_type]}",
              "typeHandlerVersion": "#{new_resource.chef_extension[:version]}",
              "settings": {
                "bootstrap_options": {
                  "chef_node_name" : "[concat(#{machine_name.delete('[]')},'.','#{new_resource.resource_group}')]",
                  "chef_server_url" : "#{chef_server_url}",
                  "validation_client_name" : "#{validation_client_name}"
                },
                "runlist": "#{new_resource.chef_extension[:runlist]}"
              },
              "protectedSettings": {
                    "validation_key": "#{validation_key_content.gsub("\n", '\\n')}"
              }
            }
          }
        EOH
      end

      def follow_deployment_until_end_state
        end_provisioning_states = 'Canceled,Failed,Deleted,Succeeded'
        end_provisioning_state_reached = false
        until end_provisioning_state_reached
          list_outstanding_deployment_operations
          sleep 5
          deployment_provisioning_state = deployment_state
          end_provisioning_state_reached = end_provisioning_states.split(',').include?(deployment_provisioning_state)
        end
        action_handler.report_progress "Resource Template deployment reached end state of '#{deployment_provisioning_state}'."
      end

      def list_outstanding_deployment_operations
        end_operation_states = 'Failed,Succeeded'
        deployment_operations = resource_management_client.deployment_operations.list(new_resource.resource_group, new_resource.name).value!
        deployment_operations.body.value.each do |val|
          resource_provisioning_state = val.properties.provisioning_state
          resource_name = val.properties.target_resource.resource_name
          resource_type = val.properties.target_resource.resource_type
          end_operation_state_reached = end_operation_states.split(',').include?(resource_provisioning_state)
          unless end_operation_state_reached
            action_handler.report_progress "Resource #{resource_type} '#{resource_name}' provisioning status is #{resource_provisioning_state}\n"
          end
        end
      end

      def deployment_state
        deployments = resource_management_client.deployments.get(new_resource.resource_group, new_resource.name).value!
        Chef::Log.debug("deployments result: #{deployments.body.inspect}")
        deployments.body.properties.provisioning_state
      end
    end
  end
end
