require 'chef/provisioning/azurerm/azure_resource'

class Chef
  class Resource
    class AzureNetworkInterface < Chef::Provisioning::AzureRM::AzureResource
      resource_name :azure_network_interface
      actions :create, :destroy, :nothing
      default_action :create
      attribute :name, kind_of: String, name_attribute: true
      attribute :resource_group, kind_of: String
      attribute :location, kind_of: String, default: 'westus'
      attribute :tags, kind_of: Hash
      attribute :private_ip_allocation_method, kind_of: String, equal_to: %w(Static Dynamic), default: 'Dynamic'
      attribute :private_ip_address, kind_of: String, regex: /^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$/
      attribute :virtual_network, kind_of: String 
      attribute :virtual_network_resource_group, kind_of: String 
      attribute :subnet, kind_of: String 
    end
  end
end
