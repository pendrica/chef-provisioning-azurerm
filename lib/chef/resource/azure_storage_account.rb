require 'chef/provisioning/azurerm/azure_resource'

# MSDN Ref: https://msdn.microsoft.com/en-us/library/azure/mt163564.aspx

class Chef
  class Resource
    class AzureStorageAccount < Chef::Provisioning::AzureRM::AzureResource
      resource_name :azure_storage_account
      actions :create, :destroy, :nothing
      default_action :create
      attribute :name, kind_of: String, name_attribute: true, regex: /^[\w]{3,24}$/i
      attribute :resource_group, kind_of: String
      attribute :location, kind_of: String, default: 'westus'
      attribute :tags, kind_of: Hash
      attribute :account_type, kind_of: String, equal_to: %w(Standard_LRS Standard_ZRS Standard_GRS Standard_RAGRS Premium_LRS), default: 'Standard_LRS'
    end
  end
end
