# chef-provisioning-azurerm

```chef-provisioning-azurerm``` is a driver for [chef-provisioning](https://github.com/chef/chef-provisioning) that allows Microsoft Azure resources to be provisioned by Chef. This driver uses the new Microsoft Azure Resource Management REST API via the [azure-sdk-for-ruby](https://github.com/azure/azure-sdk-for-ruby).

The driver provides a way to deploy Azure Resource Manager templates using Chef as well as provide an automatic means to install and register the Chef client on these machine via the use of the Chef VM Extensions for Azure.

[![Build status](https://travis-ci.org/pendrica/chef-provisioning-azurerm.svg?branch=master)](https://travis-ci.org/pendrica/chef-provisioning-azurerm) [![Gem Version](https://badge.fury.io/rb/chef-provisioning-azurerm.svg)](http://badge.fury.io/rb/chef-provisioning-azurerm) 

**Note:** If you are looking for a driver that works with the existing Microsoft Azure Service Management API please visit [chef-provisioning-azure](https://github.com/chef/chef-provisioning-azure)

## Quick-start

### Prerequisites

The plugin requires Chef Client 12.5.1 or higher.

### Installation

This plugin is distributed as a Ruby Gem. To install it, run:

```$ chef gem install chef-provisioning-azurerm```
    
### Configuration

For the driver to interact with the Microsoft Azure Resource management REST API, a Service Principal needs to be configured with Contributor rights against the specific subscription being targeted.  Using an Organization account and related password is no longer supported.  To create a Service Principal and apply the correct permissions, follow the instructions in the article: [Create an Azure service principal with Azure CLI 2.0](https://docs.microsoft.com/en-us/cli/azure/create-an-azure-service-principal-azure-cli?toc=%2fazure%2fazure-resource-manager%2ftoc.json)

You will essentially need 4 parametersto configure Chef Provisioning: **Subscription ID**, **Client ID/ID**, **Client Secret/Password** and **Tenant ID/Tenant**.

Using a text editor, open or create the file ```~/.azure/credentials``` and add the following section:

```ruby
[abcd1234-YOUR-GUID-HERE-abcdef123456]
client_id = "48b9bba3-YOUR-GUID-HERE-90f0b68ce8ba"
client_secret = "your-client-secret-here"
tenant_id = "9c117323-YOUR-GUID-HERE-9ee430723ba3"
```

Ensure you save the file as using UTF-8 encoding.

If preferred, you may also set the following environment variables on the "provisioning node", replacing the values with those obtained when you configured the service principal

```ruby
AZURE_CLIENT_ID="48b9bba3-YOUR-GUID-HERE-90f0b68ce8ba"
AZURE_CLIENT_SECRET="your-client-secret-here"
AZURE_TENANT_ID="9c117323-YOUR-GUID-HERE-9ee430723ba3"
```

Note that the environment variables, if set, take preference over the values in a configuration file.  The subscription id will be taken from the recipe.

## Features

Unlike a fully-featured **chef-provisioning** driver that fully utilises the **machine**, **machine_batch**, **machine_image** and **load_balancer** resources, the **chef-provisioning-azurerm** driver offers a lightweight way to interact with resources and providers in the Azure Resource Manager framework directly.

To work around the issue of storing chef-provisioning driver info in the Chef server:
- The Chef VM extension will automatically be configured to point at the same Chef server as the provisioning node.  This can be overridden in a recipe by using the following line: ```with_chef_server 'http://your.chef.server.url/yourorg'```

The following resources are provided:

- azure_resource_group
- azure_resource_template

The following resources are _deprecated_ and will be removed in a future version - if you want to provision individual resources in Azure you should consider alternative tooling, such as [Terraform](https://terraform.io)

- azure_storage_account
- azure_virtual_network
- azure_network_interface
- azure_public_ip_address

## Limitations
- As the nodes self-register, there are no "managed entries" created on the Chef server other than for resources of type Microsoft.Compute.
- Bootstrap over SSH or WinRM is not implemented
- Connect to machine over SSH or WinRM is not implemented
- machine, machine_batch, machine_image and load_balancer resources are not implemented
- Azure resources that can only be created through the Service Management (ASM) API are not implemented
- The path to the validation keys must be provided within the recipe (i.e. they must be in the chef-repo you are working with)
- **Local mode** is not supported - Chef VM extensions can only register themselves with a 'real' Chef server.

## Example Recipe 1 - deployment of Resource Manager template
The following recipe creates a new Resource Group within your subscription (identified by the GUID on line 2).  It will then deploy a resource template by merging the content with the parameters specified.

An ```azure_deploy.json``` is required to be copied to ```cookbooks/provision/templates/default/recipes``` - many examples of a Resource Manager deployment template can be found at the [Azure QuickStart Templates Gallery on GitHub](https://github.com/Azure/azure-quickstart-templates).

For our example, we'll need the azure_deploy.json from [here](https://github.com/Azure/azure-quickstart-templates/blob/master/101-vm-simple-windows/azuredeploy.json) and copy it to a path in our repo. Make sure you amend the path appropriately.

### example1.rb

```ruby
require 'chef/provisioning/azurerm'
with_driver 'AzureRM:abcd1234-YOUR-GUID-HERE-abcdef123456'

azure_resource_group 'pendrica-demo' do
  location 'West US'
  tags businessUnit: 'IT'
end

azure_resource_template 'my-deployment' do
  resource_group 'pendrica-demo'
  template_source "#{Chef::Config[:cookbook_path]}/provision/files/default/azure_deploy.json"
  parameters newStorageAccountName: "mystorageaccount01",
             adminUsername: 'stuart',
             adminPassword: 'P2ssw0rd',
             dnsNameForPublicIP: "my-demo-server",
             windowsOSVersion: '2012-R2-Datacenter'
  chef_extension client_type: 'ChefClient',
                 version: '1210.12',
                 runlist: 'role[webserver]'
                 environment: '_default'
end
```

**Note: If no chef_extension configuration is specified, the ARM template will be deployed without enabling the Azure Chef VM Extension.**

The Chef Server URL, Validation Client name and Validation Key content are not currently exposed parameters but are either inherited from the running configuration or can be overridden via setting the following Chef::Config parameters (via modifying ```c:\chef\client.rb``` or specifying ```-c path\to\client.rb``` on the ```chef-client``` command line).

```ruby
Chef::Config[:chef_server_url]
Chef::Config[:validation_client_name]
Chef::Config[:validation_key]
```

## Support for AzureUSGovernment, AzureChina, AzureGermanCloud environments

The driver will automatically use the correct token provider and management endpoints for the relevant cloud environment.  The default driver format for the Azure public cloud is:

```ruby
with_driver 'AzureRM:abcd1234-YOUR-GUID-HERE-abcdef123456'
```

This can be changed to one of the following formats:

```ruby
with_driver 'AzureUSGovernment:abcd1234-YOUR-GUID-HERE-abcdef123456'
```

```ruby
with_driver 'AzureChina:abcd1234-YOUR-GUID-HERE-abcdef123456'
```

```ruby
with_driver 'AzureGermanCloud:abcd1234-YOUR-GUID-HERE-abcdef123456'
```

## Contributing

Contributions to the project are welcome via submitting Pull Requests.

1. Fork it ( https://github.com/pendrica/chef-provisioning-azurerm/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

