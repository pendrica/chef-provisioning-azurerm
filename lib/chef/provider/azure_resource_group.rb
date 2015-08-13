require 'chef/provisioning/azurerm/azure_provider'

class Chef
  class Provider
    class AzureResourceGroup < Chef::Provisioning::AzureRM::AzureProvider
      provides :azure_resource_group

      def whyrun_supported?
        true
      end

      def api_url
        "https://management.azure.com/subscriptions/#{new_resource.subscription_id}/resourcegroups/" \
        "#{new_resource.name}?api-version=2015-01-01"
      end

      # API ref: https://msdn.microsoft.com/en-us/library/azure/dn790525.aspx
      action :create do
        converge_by("create or update Resource Group #{new_resource.name}") do
          doc = {
            location: new_resource.location,
            tags: new_resource.tags
          }
          azure_call_until_expected_response(:put, api_url, doc.to_json, '201,200', 60)
        end
      end

      # API ref: https://msdn.microsoft.com/en-us/library/azure/dn790539.aspx
      action :destroy do
        converge_by("destroy Resource Group #{new_resource.name}") do
          azure_call_until_expected_response(:delete, api_url, nil, '404', 60)
        end
      end
    end
  end
end
