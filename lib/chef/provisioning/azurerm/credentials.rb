require 'inifile'

class Chef
  module Provisioning
    module AzureRM
      class Credentials
        AZURE_SERVICE_PRINCIPAL = '1950a258-227b-4e31-a9cf-717495945fc2'
        CONFIG_PATH = "#{ENV['HOME']}/.azure/credentials"

        def initialize
          config_file = ENV['AZURE_CONFIG_FILE'] || File.expand_path(CONFIG_PATH)
          fail "#{CONFIG_PATH} was not found or not accessible." unless File.file?(config_file)
          @credentials = IniFile.load(File.expand_path(config_file))
        end

        def access_token_for_subscription(subscription_id)
          fail "No credentials loaded! Do you have a #{CONFIG_PATH} and a section [#{subscription_id}] within it?" \
            unless @credentials[subscription_id]
          fail "No username was found for subscription #{subscription_id}, please verify #{CONFIG_PATH}" \
            unless @credentials[subscription_id]['username']
          azure_authenticate(@credentials[subscription_id]['username'], @credentials[subscription_id]['password'])
        end

        # Do a user_impersonation to get an OAUTH2 access_token for further requests
        # - Right now this means that the entire recipe must complete with 1 hour
        # - of the token being issued (NB: the same token can be issued with that hour)
        def azure_authenticate(username, password)
          url = 'https://login.windows.net/Common/oauth2/token'
          data = "resource=https%3A%2F%2Fmanagement.core.windows.net%2F&client_id=#{AZURE_SERVICE_PRINCIPAL}" \
            "&grant_type=password&username=#{username}&scope=openid&password=#{password}"
          response = http_post(url, data)
          JSON.parse(response.body)['access_token']
        end

        def http_post(url, data)
          uri = URI(url)
          response = nil
          Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
            request = Net::HTTP::Post.new uri
            request.body = data
            response = http.request request
          end
          response
        end

        def self.singleton
          @credentials ||= Credentials.new
        end
      end
    end
  end
end
