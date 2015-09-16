require 'chef/provisioning/azurerm/azure_resource'


class Chef
  class Resource
    class AzureVirtualNetwork < Chef::Provisioning::AzureRM::AzureResource
      resource_name :azure_virtual_network
      actions :create, :destroy, :nothing
      default_action :create
      attribute :name, kind_of: String, name_attribute: true, regex: /^[\w]{3,24}$/i
      attribute :resource_group, kind_of: String
      attribute :location, kind_of: String, default: 'westus'
      attribute :tags, kind_of: Hash
      attribute :address_prefixes, kind_of: Array
      attribute :subnets, kind_of: Array
      attribute :dhcp_servers, kind_of: Array
    end
  end
end
