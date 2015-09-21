require 'chef/provisioning/azurerm/azure_resource'

class Chef
  class Resource
    class AzurePublicIPAddress < Chef::Provisioning::AzureRM::AzureResource
      resource_name :azure_public_ip_address
      actions :create, :destroy, :nothing
      default_action :create
      attribute :name, kind_of: String, name_attribute: true
      attribute :location, kind_of: String, default: 'westus'
      attribute :tags, kind_of: Hash
      attribute :resource_group, kind_of: String
      attribute :public_ip_allocation_method, kind_of: String, equal_to: %w(dynamic static), default: 'dynamic'
      attribute :dns_settings, kind_of: Hash
      attribute :idle_timeout_in_minutes, kind_of: Integer
    end
  end
end
