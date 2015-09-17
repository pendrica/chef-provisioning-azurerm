require 'kitchen'
require 'chef/provisioning'
require 'chef/provisioning/azurerm'
require 'chef/resource/azure_resource_group'

module Kitchen
  module Driver
    class AzureRM < Kitchen::Driver::Base
      default_config(:azure_resource_group_name) do |config|
        "kitchen-#{config.instance.name}-#{SecureRandom.hex(2)}"
      end

      def create(state)
        puts 'in kitchen create'
        state[:azure_resource_group_name] = config[:azure_resource_group_name]
        state[:driver_url] = config[:driver_url]

        # Create a fake run_context with just enough for chef_provisioning to run...
        run_context = Chef::RunContext.new(Chef::Node.new, {}, Chef::EventDispatch::Dispatcher.new)
        run_context.chef_provisioning.with_driver state[:driver_url]

        # Basically create a resource group, storage account, networking and compute resource via their LWRP
        resource_group = Chef::Resource::AzureResourceGroup.new(state[:azure_resource_group_name], run_context)
        resource_group.set_or_return(:location, 'West Europe', kind_of: String)
        puts resource_group.inspect
        resource_group.run_action(:create)

        storage_account_name = "ktchnstr#{SecureRandom.hex(6)}"
        storage_account = Chef::Resource::AzureStorageAccount.new(storage_account_name, run_context)
        storage_account.set_or_return(:resource_group, state[:azure_resource_group_name], kind_of: String)
        storage_account.set_or_return(:location, 'West Europe', kind_of: String)
        puts storage_account.inspect
        storage_account.run_action(:create)
      end

      def destroy(state)
        puts 'in kitchen destroy'

        # Create a fake run_context with just enough for chef_provisioning to run...
        run_context = Chef::RunContext.new(Chef::Node.new, {}, Chef::EventDispatch::Dispatcher.new)
        run_context.chef_provisioning.with_driver state[:driver_url]

        # Destroy the resource group (and all contents)
        resource_group = Chef::Resource::AzureResourceGroup.new(state[:azure_resource_group_name], run_context)
        resource_group.run_action(:destroy)
      end
    end
  end
end
