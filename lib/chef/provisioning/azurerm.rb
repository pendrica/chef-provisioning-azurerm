require 'chef/provisioning'
require 'chef/provisioning/version'
require 'chef/provisioning/azurerm/driver'
require 'chef/provisioning/azurerm/version'
Chef::Log.info('  __ _ _____   _ _ __ ___ ')
Chef::Log.info(" / _` |_  / | | | '__/ _ \\ chef-client #{Chef::VERSION}")
Chef::Log.info("| (_| |/ /| |_| | | |  __/ chef-provisioning-azurerm #{Chef::Provisioning::AzureRM::VERSION}")
Chef::Log.info(" \\__,_/___|\\__,_|_|  \\___| chef-provisioning #{Chef::Provisioning::VERSION}")

resources = %w(resource_group resource_template storage_account)
resources.each do |r|
  require "chef/resource/azure_#{r}"
  require "chef/provider/azure_#{r}"
end
