require 'chef/provisioning/azurerm/azure_resource'

class Chef
  class Resource
    class AzureVirtualNetwork < Chef::Provisioning::AzureRM::AzureResource
      resource_name :azure_virtual_network
      actions :create, :destroy, :nothing
      default_action :create
      attribute :name, kind_of: String, name_attribute: true
      attribute :resource_group, kind_of: String
      attribute :location, kind_of: String, default: 'westus'
      attribute :tags, kind_of: Hash
      attribute :address_prefixes, kind_of: Array, :callbacks => {
          'should be an array of subnets in CIDR format (nnn.nnn.nnn.nnn/nn)' => lambda { 
            |arg_array|  arg_array.each do |subnet|
              return false unless subnet =~
                /^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])(\/([0-9]|[1-2][0-9]|3[0-2]))$/ 
            end
            return true
            }
      }
      attribute :subnets, kind_of: Array, :callbacks => {
          'should be an array of subnet hashes, each with a :name and :address_prefix' => lambda { 
            |arg_array|  arg_array.each do |subnet|
              return false unless ([ :name, :address_prefix].sort == subnet.keys.sort)
            end
            return true
            }
      }
      attribute :dns_servers, kind_of: Array, :callbacks => {
          'should be an array of ip addresses' => lambda { 
            |arg_array|  arg_array.each do |subnet|
              return false unless subnet =~
                /^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$/
            end
            return true
            }
      }
    end
  end
end
