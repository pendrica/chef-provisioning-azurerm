require 'chef/provisioning/azurerm/azure_resource'

class Chef
  class Resource
    class AzureNetworkInterface < Chef::Provisioning::AzureRM::AzureResource
      resource_name :azure_network_interface
      actions :create, :destroy, :nothing
      default_action :create
      attribute :name, kind_of: String, name_attribute: true, regex: /^[\w\-\(\)\.]{0,80}$+(?<!\.)$/i
      attribute :resource_group, kind_of: String
      attribute :location, kind_of: String, default: 'westus'
      attribute :tags, kind_of: Hash
      attribute :private_ip_allocation_method, kind_of: String, equal_to: %w(static dynamic), default: 'dynamic'
      attribute :private_ip_address, kind_of: String, regex: /^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$/
      attribute :virtual_network, kind_of: String
      attribute :virtual_network_resource_group, kind_of: String
      attribute :subnet, kind_of: String
      attribute :dns_servers, kind_of: Array, callbacks: {
        'should be an array of ip addresses' => lambda do |arg_array|
          arg_array.each do |subnet|
            return false unless subnet =~ /^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$/
          end
          return true
        end
      }
    end
  end
end
