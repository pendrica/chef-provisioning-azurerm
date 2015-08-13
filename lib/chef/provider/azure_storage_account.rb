require 'chef/provisioning/azurerm/azure_provider'

# MSDN: https://msdn.microsoft.com/en-us/library/azure/mt163564.aspx

class Chef
  class Provider
    class AzureStorageAccount < Chef::Provisioning::AzureRM::AzureProvider
      provides :azure_storage_account

      def whyrun_supported?
        true
      end

      action :create do
        url = "https://management.azure.com/subscriptions/#{new_resource.subscription_id}/resourcegroups/" \
              "#{new_resource.resource_group}/providers/Microsoft.Storage/storageAccounts/#{new_resource.name}" \
              '?api-version=2015-05-01-preview'
        doc = {
          location: new_resource.location,
          tags: new_resource.tags,
          properties: {
            accountType: "#{new_resource.account_type}"
          }
        }
        converge_by("create or update Storage Account: #{new_resource.name}") do
          azure_call_until_expected_response(:put, url, doc.to_json, '201,200', 600)
        end
      end

      action :destroy do
        url = "https://management.azure.com/subscriptions/#{new_resource.subscription_id}/resourcegroups/" \
              "#{new_resource.resource_group}/providers/Microsoft.Storage/storageAccounts/#{new_resource.name}" \
              '?api-version=2015-05-01-preview'
        converge_by("destroy Storage Account: #{new_resource.name}") do
          azure_call_until_expected_response(:delete, url, nil, '404', 600)
        end
      end
    end
  end
end
