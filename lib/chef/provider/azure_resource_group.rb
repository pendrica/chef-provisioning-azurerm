require 'chef/provisioning/azurerm/azure_provider'

class Chef
  class Provider
    class AzureResourceGroup < Chef::Provisioning::AzureRM::AzureProvider
      provides :azure_resource_group

      def whyrun_supported?
        true
      end

      action :create do
        converge_by("create or update Resource Group #{new_resource.name}") do
          begin
            resource_group = Azure::ARM::Resources::Models::ResourceGroup.new
            resource_group.location = new_resource.location
            resource_group.tags = new_resource.tags
            result = resource_management_client.resource_groups.create_or_update(new_resource.name, resource_group)
            Chef::Log.debug("result: #{result.inspect}")
          rescue ::MsRestAzure::AzureOperationError => operation_error
            Chef::Log.error operation_error.response.body
            raise operation_error.response.inspect
          end
        end
      end

      action :destroy do
        converge_by("destroy Resource Group #{new_resource.name}") do
          resource_group_exists = resource_management_client.resource_groups.check_existence(new_resource.name)
          if resource_group_exists
            result = resource_management_client.resource_groups.delete(new_resource.name)
            Chef::Log.debug("result: #{result.inspect}")
          else
            action_handler.report_progress "Resource Group #{new_resource.name} was not found."
          end
        end
      end
    end
  end
end
