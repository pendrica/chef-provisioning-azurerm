require 'chef/provisioning/azurerm/azure_provider'

class Chef
  class Provider
    class AzureStorageAccount < Chef::Provisioning::AzureRM::AzureProvider
      provides :azure_storage_account

      def whyrun_supported?
        true
      end

      action :create do
        # Does the storage account already exist in the specified resource group?
        storage_account_exists = does_storage_account_exist

        # If the storage account already exists, do an update
        if storage_account_exists
          converge_by("update Storage Account #{new_resource.name}") do
            update_storage_account
          end
        else
          # Create the storage account complete with tags and properties
          converge_by("create Storage Account #{new_resource.name}") do
            create_storage_account
            # now update the resource with properties that are not settable in the create operation (e.g. create domain)
            update_storage_account
          end
        end
      end

      action :destroy do
        converge_by("destroy Storage Account: #{new_resource.name}") do
          storage_account_exists = does_storage_account_exist
          if storage_account_exists
            action_handler.report_progress 'destroying Storage Account'
            storage_management_client.storage_accounts.delete(new_resource.resource_group, new_resource.name)
          else
            action_handler.report_progress "Storage Account #{new_resource.name} was not found."
          end
        end
      end

      def does_storage_account_exist
        storage_account_list = storage_management_client.storage_accounts.list_by_resource_group(new_resource.resource_group)
        storage_account_list.value.each do |storage_account|
          return true if storage_account.name == new_resource.name
        end
        false
      end

      def create_storage_account
        storage_account = Azure::ARM::Storage::Models::StorageAccountCreateParameters.new
        storage_account.location = new_resource.location
        storage_account.tags = new_resource.tags
        storage_account.properties = Azure::ARM::Storage::Models::StorageAccountPropertiesCreateParameters.new
        storage_account.properties.account_type = new_resource.account_type
        action_handler.report_progress 'creating Storage Account'
        result = storage_management_client.storage_accounts.create(new_resource.resource_group, new_resource.name, storage_account)
        Chef::Log.debug(result)
      end

      def update_storage_account
        update_storage_account_tags
        update_storage_account_account_type
        update_storage_account_custom_domain
      end

      def update_storage_account_tags
        storage_account = Azure::ARM::Storage::Models::StorageAccountUpdateParameters.new
        storage_account.tags = new_resource.tags
        storage_account.properties = Azure::ARM::Storage::Models::StorageAccountPropertiesUpdateParameters.new
        action_handler.report_progress 'updating Tags'
        result = storage_management_client.storage_accounts.update(new_resource.resource_group, new_resource.name, storage_account)
        Chef::Log.debug(result)
      end

      def update_storage_account_account_type
        storage_account = Azure::ARM::Storage::Models::StorageAccountUpdateParameters.new
        storage_account.properties = Azure::ARM::Storage::Models::StorageAccountPropertiesUpdateParameters.new
        storage_account.properties.account_type = new_resource.account_type
        action_handler.report_progress 'updating Properties'
        result = storage_management_client.storage_accounts.update(new_resource.resource_group, new_resource.name, storage_account)
        Chef::Log.debug(result)
      end

      def update_storage_account_custom_domain
        storage_account = Azure::ARM::Storage::Models::StorageAccountUpdateParameters.new
        storage_account.properties = Azure::ARM::Storage::Models::StorageAccountPropertiesUpdateParameters.new
        custom_domain = Azure::ARM::Storage::Models::CustomDomain.new
        custom_domain.name = new_resource.custom_domain
        storage_account.properties.custom_domain = custom_domain
        action_handler.report_progress 'updating Custom Domain'
        result = storage_management_client.storage_accounts.update(new_resource.resource_group, new_resource.name, storage_account)
        Chef::Log.debug(result)
      end
    end
  end
end
