#
# Cookbook Name:: chef-provisioning-azurerm-examples
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

require 'chef/provisioning/azurerm'
with_driver 'AzureRM:b6e7eee9-e4cd-41ae-8432-03ab624df016'

azure_resource_group 'chef-provisioning_examples_resource_group' do
  location 'West Europe'
  tags hello: 'world'
  action :create
end

# azure_resource_group 'chef-provisioning_examples_resource_group' do
#   action :destroy
# end
