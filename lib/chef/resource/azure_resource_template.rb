require 'chef/provisioning/azurerm/azure_resource'

class Chef
  class Resource
    class AzureResourceTemplate < Chef::Provisioning::AzureRM::AzureResource
      resource_name :azure_resource_template
      actions :deploy, :validate, :nothing
      default_action :deploy
      attribute :name, kind_of: String, name_attribute: true
      attribute :resource_group, kind_of: String
      attribute :template_source, kind_of: String
      attribute :parameters, kind_of: Hash
      attribute :outputs, kind_of: Hash
    end
  end
end
