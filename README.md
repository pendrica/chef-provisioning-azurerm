# chef-provisioning-azurerm

```chef-provisioning-azurerm``` is a driver for [chef-provisioning](https://github.com/chef/chef-provisioning) that allows Microsoft Azure resources to be provisioned by Chef. This driver uses the new Microsoft Azure Resource Management REST API via the [azure-sdk-for-ruby](https://github.com/azure/azure-sdk-for-ruby).

The driver provides a way to deploy Azure Resource Manager templates using Chef as well as provide an automatic means to install and register the Chef client on these machine via the use of the Chef VM Extensions for Azure.

[![Build status](https://travis-ci.org/pendrica/chef-provisioning-azurerm.svg?branch=master)](https://travis-ci.org/pendrica/chef-provisioning-azurerm) [![Gem Version](https://badge.fury.io/rb/chef-provisioning-azurerm.svg)](http://badge.fury.io/rb/chef-provisioning-azurerm) 

**Note:** If you are looking for a driver that works with the existing Microsoft Azure Service Management API please visit [chef-provisioning-azure](https://github.com/chef/chef-provisioning-azure)

## Quick-start

### Prerequisites

The plugin requires Chef Client 12.2.1 or higher.

### Installation

This plugin is distributed as a Ruby Gem. To install it, run:

```$ chef gem install chef-provisioning-azurerm```
    
### Configuration

For the driver to interact with the Microsoft Azure Resource management REST API, a Service Principal needs to be configured with Owner rights against the specific subscription being targeted.  Using an Organization account and related password is no longer supported.  To create a Service Principal and apply the correct permissions, follow the instructions in the article: [Authenticating a service principal with Azure Resource Manager](https://azure.microsoft.com/en-us/documentation/articles/resource-group-authenticate-service-principal/#authenticate-service-principal-with-password---azure-cli)   

You will essentially need 4 parameters from the above article to configure Chef Provisioning: **Subscription ID**, **Client ID**, **Client Secret/Password** and **Tenant ID**.  These can be easily obtained using the azure-cli tools (v0.9.8 or higher) on any platform.

Using a text editor, open or create the file ```~/.azure/credentials``` and add the following section:

```ruby
[abcd1234-YOUR-GUID-HERE-abcdef123456]
client_id = "48b9bba3-YOUR-GUID-HERE-90f0b68ce8ba"
client_secret = "your-client-secret-here"
tenant_id = "9c117323-YOUR-GUID-HERE-9ee430723ba3"
```

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
- azure_storage_account
- azure_virtual_network
- azure_network_interface
- azure_public_ip_address

The following resources are planned (note: these resources may be renamed as they are implemented):

- azure_availability_set
- azure_load_balancer
- azure_network_security_group
- azure_virtual_machine
- PaaS resources such as TrafficManager, SQL Server etc.

## Limitations
- As the nodes self-register, there are no "managed entries" created on the Chef server other than for resources of type Microsoft.Compute.
- Bootstrap over SSH or WinRM is not implemented
- Connect to machine over SSH or WinRM is not implemented
- machine, machine_batch, machine_image and load_balancer resources are not implemented
- Azure resources that can only be created through the Service Management (ASM) API are not implemented
- The path to the validation keys must be provided within the recipe (i.e. they must be in the chef-repo you are working with)
- **Local mode** is not currently supported - the Chef VM extensions can only register themselves with a 'real' Chef server.
 
## Example Recipe 1 - deployment of Resource Manager template
The following recipe creates a new Resource Group within your subscription (identified by the GUID on line 2).  It will then execute a resource template by merging the content at the given uri with the parameters specified.

A ```deployment_template.json``` is required to be copied to ```cookbooks/provision/templates/default/recipes``` - many examples of a Resource Manager deployment template can be found at the [Azure QuickStart Templates Gallery on GitHub](https://github.com/Azure/azure-quickstart-templates).

For our example, we'll need the azure_deploy.json from [here](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/101-simple-windows-vm/azuredeploy.json) and copy it to a path in our repo. Make sure you amend the path appropriately. 

### example1.rb

```ruby
require 'chef/provisioning/azurerm'
with_driver 'AzureRM:abcd1234-YOUR-GUID-HERE-abcdef123456'

azure_resource_group 'pendrica-demo' do
  location 'West US' # optional, default: 'West US'
  tags businessUnit: 'IT' # optional
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
end
```

**Note: If no chef_extension configuration is specified, the ARM template will imported without enabling the Azure Chef VM Extension.**

The Chef Server URL, Validation Client name and Validation Key content are not currently exposed parameters but can be overridden via setting the following Chef::Config parameters (via modifying ```c:\chef\client.rb``` or specifying ```-c path\to\client.rb``` on the ```chef-client``` command line). 

```ruby
Chef::Config[:chef_server_url]
Chef::Config[:validation_client_name]
Chef::Config[:validation_key]
```

## Example Recipe 2 - deployment of locally replicated Storage Account
### example2.rb

```ruby
require 'chef/provisioning/azurerm'
with_driver 'AzureRM:abcd1234-YOUR-GUID-HERE-abcdef123456'

azure_resource_group 'pendrica-demo' do
  location 'West US'
end

azure_storage_account 'mystorageaccount02' do
  resource_group 'pendrica-demo'
  location 'West US'
  account_type 'Standard_LRS'
end
```
 
## Example Recipe 3 - deployment of Virtual Network
This example creates a virtual network named 'myvnet' in the pendrica-demo 
resource group in the West US region.  This virtual network contains 4 subnets
in the 10.123.123.0/24 CIDR block.  The specified DNS servers will be used
used by VMs in this virtual network.

**Note that if dns_servers are not specified, the default azure dns will
be used.

### example3.rb

```ruby
require 'chef/provisioning/azurerm'
with_driver 'AzureRM:abcd1234-YOUR-GUID-HERE-abcdef123456'

azure_resource_group 'pendrica-demo' do
  location 'West US'
end

azure_virtual_network 'myvnet' do
  action :create
  resource_group 'pendrica-demo'
  location 'West US'
  address_prefixes ['10.123.123.0/24' ] 
  subnets [
  { name: 'infrastructure', address_prefix: '10.123.123.0/28' },
  { name: 'data', address_prefix: '10.123.123.32/27' },
  { name: 'app', address_prefix: '10.123.123.64/26' },
  { name: 'web', address_prefix: '10.123.123.128/25' },
  ]
  dns_servers ['10.123.123.5', '10.123.123.6']
  tags environment: 'test', 
       owner: 'jsmyth'  
end


```

## Example Recipe 4 - deployment of Network Interface
This example creates a network interface named mynic2 on  the 'web' subnet of a virtual network named 'myvnet'.  

### example4.rb

```ruby
azure_network_interface 'mynic2' do
  action :create
  resource_group 'pendrica-demo'
  location 'West US'
  virtual_network 'myvnet'
  subnet 'web' 
end
```

## Example Recipe 5 - deployment of Network Interface with a private static address and a public IP
This example creates a network interface named mynic on the 'web' subnet of a virtual network named 'myvnet'.  This interface
has a statically assigned IP address and dns servers, as well as a dynamically assigned Public IP address.

### example5.rb

```ruby
azure_network_interface 'mynic' do
  action :create
  resource_group 'pendrica-demo'
  location 'West US'
  virtual_network 'myvnet'
  subnet 'web' 
  private_ip_allocation_method 'static'
  private_ip_address '10.123.123.250'
  dns_servers ['10.123.123.5', '10.123.123.6']
  public_ip 'mynic-pip' do
    public_ip_allocation_method 'dynamic'
    domain_name_label 'mydnsname'
    idle_timeout_in_minutes 15
    tags environment: 'test', 
        owner: 'jsmyth'  
  end
end

```

## Contributing

Contributions to the project are welcome via submitting Pull Requests.

1. Fork it ( https://github.com/pendrica/chef-provisioning-azurerm/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

