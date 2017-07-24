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
          credentials = Credentials.new.azure_credentials_for_subscription(new_resource.subscription_id, new_resource.driver_name)
          client = Azure::ARM::Resources::ResourceManagementClient.new(credentials, resource_manager_endpoint_url(new_resource.driver_name))
          client.subscription_id = new_resource.subscription_id
          client
        end

        def storage_management_client
          credentials = Credentials.new.azure_credentials_for_subscription(new_resource.subscription_id, new_resource.driver_name)
          client = Azure::ARM::Storage::StorageManagementClient.new(credentials, resource_manager_endpoint_url(new_resource.driver_name))
          client.subscription_id = new_resource.subscription_id
          client
        end

        def compute_management_client
          credentials = Credentials.new.azure_credentials_for_subscription(new_resource.subscription_id, new_resource.driver_name)
          client = Azure::ARM::Compute::ComputeManagementClient.new(credentials, resource_manager_endpoint_url(new_resource.driver_name))
          client.subscription_id = new_resource.subscription_id
          client
        end

        def network_management_client
          credentials = Credentials.new.azure_credentials_for_subscription(new_resource.subscription_id, new_resource.driver_name)
          client = Azure::ARM::Network::NetworkResourceProviderClient.new(credentials, resource_manager_endpoint_url(new_resource.driver_name))
          client.subscription_id = new_resource.subscription_id
          client
        end

        def resource_manager_endpoint_url(azure_environment)
          case azure_environment.downcase
          when 'azureusgovernment'
            MsRestAzure::AzureEnvironments::AzureUSGovernment.resource_manager_endpoint_url
          when 'azurechina'
            MsRestAzure::AzureEnvironments::AzureChinaCloud.resource_manager_endpoint_url
          when 'azuregermancloud'
            MsRestAzure::AzureEnvironments::AzureGermanCloud.resource_manager_endpoint_url
          when 'azurerm'
            MsRestAzure::AzureEnvironments::AzureCloud.resource_manager_endpoint_url
          when 'azure'
            MsRestAzure::AzureEnvironments::AzureCloud.resource_manager_endpoint_url
          end
        end

        def try_azure_operation(description, silently_continue_on_error = false)
          begin
            result = yield
          rescue MsRestAzure::AzureOperationError => operation_error
            unless silently_continue_on_error
              error = operation_error.body['error']
              Chef::Log.error "ERROR #{description} - #{error}"
              raise operation_error
            end
          end

          result
        end
      end
    end
  end
end
