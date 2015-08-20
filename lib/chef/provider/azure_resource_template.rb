require 'chef/provisioning/azurerm/azure_provider'

class Chef
  class Provider
    class AzureResourceTemplate < Chef::Provisioning::AzureRM::AzureProvider
      provides :azure_resource_template

      def whyrun_supported?
        true
      end

      # Applies a Resource Manager template to Azure.
      # If resources of type Microsoft.Compute/virtualMachines are found, a Chef VM Extension is added
      # Chef VM Extension parameters may be supplied in the recipe.
      action :deploy do
        converge_by("deploy or re-deploy Resource Manager template '#{new_resource.name}'") do
          template_src_file = ::File.join(Chef::Config[:chef_repo_path], new_resource.template_source)
          fail "Cannot find file: #{template_src_file}" unless ::File.file?(template_src_file)
          template_src = ::IO.read(template_src_file)
          template = JSON.parse(template_src)
          if new_resource.chef_extension
            machines = template['resources'].select { |h| h['type'] == 'Microsoft.Compute/virtualMachines' }
            machines.each do |machine|
              Chef::Log.info("[Azure] Found a compute resource with name value: #{machine['name']} and location #{machine['location']}, adding a Chef VM Extension to it.")
              extension = chef_vm_extension(machine['name'], machine['location'])
              template['resources'] << JSON.parse(extension)
            end
          end
          Chef::Log.debug("[Azure] Generated template for deployment: #{template}")
          doc = generate_wrapper_document(template)
          apply_template_deployment(doc)
          follow_deployment_until_ended
        end
      end

      def generate_wrapper_document(template)
        parameters = new_resource.parameters.map do |key, value|
          { key.to_sym => { 'value' => value } }
        end
        new_template = {
          properties: {
            template: template,
            mode: 'Incremental',
            parameters: parameters.reduce(:merge!)
          }
        }
        new_template
      end

      def chef_vm_extension(machine_name, location)
        Chef::Log.debug("[Azure] Config: #{Chef::Config.inspect}")
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

      def apply_template_deployment(doc)
        url = "https://management.azure.com/subscriptions/#{new_resource.subscription_id}/resourcegroups/" \
              "#{new_resource.resource_group}/providers/microsoft.resources/deployments/#{new_resource.name}" \
              '?api-version=2015-01-01'
        azure_call(:put, url, doc.to_json)
      end

      def validate_template_deployment(doc)
        url = "https://management.azure.com/subscriptions/#{new_resource.subscription_id}/resourcegroups/" \
          "#{new_resource.resource_group}/providers/microsoft.resources/deployments/#{new_resource.name}" \
          '/validate?api-version=2015-01-01'
        response = azure_call(:post, url, doc.to_json)
        Chef::Log.info("[Azure] #{response.body.inspect}")
      end

      # API ref: https://msdn.microsoft.com/en-us/library/azure/dn790565.aspx (Deployment)
      # API ref: https://msdn.microsoft.com/en-us/library/azure/dn790519.aspx (Operations)
      def follow_deployment_until_ended
        url = "https://management.azure.com/subscriptions/#{new_resource.subscription_id}/resourcegroups/" \
          "#{new_resource.resource_group}/providers/microsoft.resources/deployments/#{new_resource.name}" \
          '/operations?api-version=2015-01-01'

        end_provisioning_states = 'Canceled,Failed,Deleted,Succeeded'
        end_operation_states = 'Failed,Succeeded'
        end_provisioning_state_reached = false

        until end_provisioning_state_reached
          response = azure_call(:get, url, '')
          deployment_operations = JSON.parse(response.body)
          deployment_operations['value'].each do |val|
            resource_provisioning_state = val['properties']['provisioningState']
            resource_name = val['properties']['targetResource']['resourceName']
            resource_type = val['properties']['targetResource']['resourceType']
            end_operation_state_reached = end_operation_states.split(',').include?(resource_provisioning_state)
            unless end_operation_state_reached
              Chef::Log.info("[Azure] Resource #{resource_type} '#{resource_name}' provisioning status is #{resource_provisioning_state}")
            end
          end
          sleep 5
          provisioning_state = retrieve_provisioning_state
          Chef::Log.debug("[Azure] Resource Template deployment is in a state of '#{provisioning_state}'")
          end_provisioning_state_reached = end_provisioning_states.split(',').include?(provisioning_state)
        end
        Chef::Log.info("[Azure] Resource Template deployment reached end state of '#{provisioning_state}'")
      end

      def retrieve_provisioning_state
        url = "https://management.azure.com/subscriptions/#{new_resource.subscription_id}/resourcegroups/" \
          "#{new_resource.resource_group}/providers/microsoft.resources/deployments/#{new_resource.name}" \
          '?api-version=2015-01-01'
        response = azure_call(:get, url, '')
        JSON.parse(response.body)['properties']['provisioningState']
      end
    end
  end
end
