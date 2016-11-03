#
# Cookbook Name:: arm-examples
# Recipe:: resource_group.rb
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

require 'chef/provisioning/azurerm'
with_driver "AzureRM:#{node['chef-provisioning-azurerm']['subscription-id']}"

azure_resource_group 'chef-provisioning_examples_resource_group' do
  location 'West Europe'
  tags hello: 'world'
  action :create
end

# azure_resource_group 'chef-provisioning_examples_resource_group' do
#   action :destroy
# end
