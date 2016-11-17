#
# Cookbook Name:: arm-examples
# Recipe:: resource_group.rb
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

require 'chef/provisioning/azurerm'
with_driver 'AzureRM:b6e7eee9-YOUR-GUID-HERE-03ab624df016'

azure_resource_group 'chef-provisioning_examples_resource_template10' do
  location 'West Europe'
  tags hello: 'world'
  action :create
end

azure_resource_template 'my-deployment10' do
  resource_group 'chef-provisioning_examples_resource_template10'
  template_source "#{Chef::Config[:cookbook_path]}/arm-examples/templates/azuredeploy.json"
  parameters  dnsLabelPrefix: 'pndrcww10',
              vmName: 'pndrcww10',
              adminUsername: 'azure',
              adminPassword: 'P2ssw0rd',
              rdpPort: 3389
end

# azure_resource_group 'chef-provisioning_examples_resource_template' do
#   action :destroy
# end
