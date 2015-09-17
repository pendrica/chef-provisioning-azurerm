require 'chef/provisioning'
require 'chef/provisioning/version'
require 'chef/provisioning/azurerm/driver'
require 'chef/provisioning/azurerm/version'
require 'azure_mgmt_resources'
require 'azure_mgmt_storage'
require 'azure_mgmt_compute'
require 'azure_mgmt_network'

Chef::Log.info("chef-provisioning-azurerm #{Chef::Provisioning::AzureRM::VERSION}")
Chef::Log.info("chef-provisioning #{Chef::Provisioning::VERSION}")

resources = %w(resource_group resource_template storage_account virtual_network network_interface)
resources.each do |r|
  require "chef/resource/azure_#{r}"
  require "chef/provider/azure_#{r}"
end
