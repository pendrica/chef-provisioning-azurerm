require 'inifile'

class Chef
  module Provisioning
    module AzureRM
      class Credentials
        CONFIG_PATH = "#{ENV['HOME']}/.azure/credentials".freeze

        def initialize
          config_file = ENV['AZURE_CONFIG_FILE'] || File.expand_path(CONFIG_PATH)
          if File.file?(config_file)
            @credentials = IniFile.load(File.expand_path(config_file))
          else
            Chef::Log.warn "#{CONFIG_PATH} was not found or not accessible." unless File.file?(config_file)
          end
        end

        def azure_credentials_for_subscription(subscription_id, azure_environment)
          tenant_id = ENV['AZURE_TENANT_ID'] || @credentials[subscription_id]['tenant_id']
          client_id = ENV['AZURE_CLIENT_ID'] || @credentials[subscription_id]['client_id']
          client_secret = ENV['AZURE_CLIENT_SECRET'] || @credentials[subscription_id]['client_secret']
          token_provider = MsRestAzure::ApplicationTokenProvider.new(tenant_id, client_id, client_secret, settings_for_azure_environment(azure_environment))
          MsRest::TokenCredentials.new(token_provider)
        end

        #
        # Retrieves a [MsRestAzure::ActiveDirectoryServiceSettings] object representing the settings for the given cloud.
        # @param azure_environment [String] The Azure environment to retrieve settings for.
        #
        # @return [MsRestAzure::ActiveDirectoryServiceSettings] Settings to be used for subsequent requests
        #
        def settings_for_azure_environment(azure_environment)
          case azure_environment.downcase
          when 'azureusgovernment'
            ::MsRestAzure::ActiveDirectoryServiceSettings.get_azure_us_government_settings
          when 'azurechina'
            ::MsRestAzure::ActiveDirectoryServiceSettings.get_azure_china_settings
          when 'azuregermancloud'
            ::MsRestAzure::ActiveDirectoryServiceSettings.get_azure_german_settings
          when 'azurerm'
            ::MsRestAzure::ActiveDirectoryServiceSettings.get_azure_settings
          when 'azure'
            ::MsRestAzure::ActiveDirectoryServiceSettings.get_azure_settings
          end
        end

        def self.singleton
          @credentials ||= Credentials.new
        end
      end
    end
  end
end
