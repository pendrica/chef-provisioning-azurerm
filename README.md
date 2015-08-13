# chef-provisioning-azurerm

```chef-provisioning-azurerm``` is a driver for [chef-provisioning](https://github.com/chef/chef-provisioning) that allows Microsoft Azure resources to be provisioned by Chef. This driver uses the new Microsoft Azure Resource Management REST API.

At the moment, the primary use case is to provide a way to deploy Azure Resource Manager templates using Chef as well as provide an automatic means to install and register the Chef client on these machine via the use of the Chef VM Extensions for Azure.

![build status](https://travis-ci.org/pendrica/chef-provisioning-azurerm.svg?branch=master)

**Note:** If you are looking for a driver that works with the existing Microsoft Azure Service Management API please visit [chef-provisioning-azure](https://github.com/chef/chef-provisioning-azure)

## Quick-start

### Prerequisites

The plugin requires Chef Client 12.2.1 or higher.

### Installation

This plugin is distributed as a Ruby Gem. To install it, run:

```$ chef gem install chef-provisioning-azurerm```
    
### Configuration

For the driver to interact with the Microsoft Azure Resource management REST API, a username and password needs to be configured that refer to an account with the role 'Service Administrator'.

*Unlike the Microsoft Azure Service Management API which performs authentication via X.509 v3 certificates, the Resource Management API requires an OAUTH2 authentication token to be passed with each request.  To obtain the token, a username and password is used.*

Using a text editor, open or create the file ```~/.azure/credentials``` and add the following section:

```ruby
[abcd1234-YOUR-GUID-HERE-abcdef123456]
username = "username@tenant.onmicrosoft.com"
password = "your-password-here"
```

The GUID required is that of your Azure subscription.  This can be found after logging into the portal at https://portal.azure.com 

**Note:** Storage of the password is required due to the generated access token only being valid for 3600 seconds each time it is generated [1].

[1] https://twitter.com/vibronet/status/461260062204239872

## Features

Unlike a fully-featured **chef-provisioning** driver that fully utilises the **machine**, **machine_batch**, **machine_image** and **load_balancer** resources, the **chef-provisioning-azurerm** driver offers a lightweight way to interact with resources and providers in the Azure Resource Manager framework directly.

To work around the issue of storing chef-provisioning driver info in the Chef server:  
- Any Azure Resource Manager (ARM) templates sent for deployment that contain a resource of type 'Microsoft.Compute/virtualMachine' or 'Microsoft.ClassicCompute/virtualMachine' will automatically have the Chef VM extension added (unless overridden with **install_vm_extension: false**)
- The Chef VM extension will automatically be configured to point at the same Chef server as the provisioning node.  This can be overridden in a recipe by using the following line: ```with_chef_server 'http://your.chef.server.url/yourorg'```

The following resources are provided: 

- azure_resource_group
- azure_storage_account
- azure_resource_template

The following resources are planned:

- azure_virtual_network
- azure_availability_set
- azure_load_balancer
- azure_network_interface
- azure_network_security_group
- azure_public_ip_address
- azure_virtual_machine

## Limitations
- There are no "managed entries" created on the Chef server other than for resources of type Microsoft.Compute.
- Bootstrap over SSH or WinRM is not implemented
- Connect to machine over SSH or WinRM is not implemented
- machine, machine_batch, machine_image and load_balancer resources are not implemented
- Azure resources that can only be created through the Service Management (ASM) API are not implemented
- Validation keys to allow new resources to register themselves must be provided within the recipe
 
## Example Recipe 1 - deployment of Resource Manager template
The following recipe creates a new Resource Group within your subscription (identified by the GUID on line 2).  It will then execute a resource template by merging the content at the given uri with the parameters specified.

### example1.rb

```ruby
require 'chef/provisioning/azurerm'
with_driver 'azurerm:abcd1234-YOUR-GUID-HERE-abcdef123456'

azure_resource_group 'pendrica-demo-resources' do
  location 'West US' # optional, default: 'West US'
  tags businessUnit: 'IT' # optional
end

azure_resource_template 'my-deployment' do
  resource_group 'pendrica-demo-resources'
  template_source 'azuredeploy.json'
  parameters newStorageAccountName: 'penstorage01',
             adminUsername: 'ubuntu',
             adminPassword: 'P2ssw0rd',
             dnsNameForPublicIP: 'pendricatest01',
             ubuntuOSVersion: '14.04.2-LTS'
end
```

### execution

```chef-client --local example1.rb --minimal-ohai```

## Example Recipe 2 - deployment of locally replicated Storage Account

### example2.rb

```ruby
require 'chef/provisioning/azurerm'
with_driver 'azurerm:abcd1234-YOUR-GUID-HERE-abcdef123456'

azure_resource_group 'pendrica-demo-resources' do
  location 'West US'
end

azure_storage_account 'pendevstore01' do
  resource_group 'pendrica-demo-resources'
  location 'West US'
  account_type 'Standard_LRS'
end
```
 
## Contributing

Contributions to the project are welcome via submitting Pull Requests.

1. Fork it ( https://github.com/pendrica/chef-provisioning-azurerm/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

