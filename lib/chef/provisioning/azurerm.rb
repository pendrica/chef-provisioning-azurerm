require 'chef/provisioning'
require 'chef/provisioning/version'
require 'chef/provisioning/azurerm/driver'
require 'chef/provisioning/azurerm/version'
Chef::Log.info("chef-provisioning-azurerm #{Chef::Provisioning::AzureRM::VERSION}")
Chef::Log.info("chef-provisioning #{Chef::Provisioning::VERSION}")

resources = %w(resource_group resource_template storage_account)
resources.each do |r|
  require "chef/resource/azure_#{r}"
  require "chef/provider/azure_#{r}"
end
