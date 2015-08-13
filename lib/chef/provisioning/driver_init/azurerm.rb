require 'chef/provisioning/azurerm/driver'
Chef::Provisioning.register_driver_class('AzureRM', Chef::Provisioning::AzureRM::Driver)
