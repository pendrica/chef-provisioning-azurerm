require 'chef/provider/lwrp_base'
require 'chef/provisioning/azurerm/azure_resource'
require 'chef/provisioning/chef_provider_action_handler'

class Chef
  module Provisioning
    module AzureRM
      class AzureProvider < Chef::Provider::LWRPBase
        use_inline_resources

        def action_handler
          @action_handler ||= Chef::Provisioning::ChefProviderActionHandler.new(self)
        end

        def resource_management_client
          credentials = Credentials.new.azure_credentials_for_subscription(new_resource.subscription_id)
          client = Azure::ARM::Resources::ResourceManagementClient.new(credentials)
          client.subscription_id = new_resource.subscription_id
          client
        end

        def storage_management_client
          credentials = Credentials.new.azure_credentials_for_subscription(new_resource.subscription_id)
          client = Azure::ARM::Storage::StorageManagementClient.new(credentials)
          client.subscription_id = new_resource.subscription_id
          client
        end

        def compute_management_client
          credentials = Credentials.new.azure_credentials_for_subscription(new_resource.subscription_id)
          client = Azure::ARM::Compute::ComputeManagementClient.new(credentials)
          client.subscription_id = new_resource.subscription_id
          client
        end

        def network_management_client
          credentials = Credentials.new.azure_credentials_for_subscription(new_resource.subscription_id)
          client = Azure::ARM::Network::NetworkResourceProviderClient.new(credentials)
          client.subscription_id = new_resource.subscription_id
          client
        end

        def try_azure_operation(description)
          begin
            result = yield
          rescue MsRestAzure::AzureOperationError => operation_error
            error = operation_error.body['error']
            Chef::Log.error "ERROR #{description} - #{error}"
            raise operation_error
          end

          result
        end
      end
    end
  end
end
