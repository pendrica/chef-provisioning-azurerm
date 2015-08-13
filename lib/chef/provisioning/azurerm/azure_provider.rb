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

        # Makes a call to the specified REST API, adding the Azure bearer token.
        def azure_call(method, url, data)
          Chef::Log.debug("HTTP request: #{method} #{url} #{data.to_json}")
          uri = URI(url)
          response = nil
          Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
            case method
            when :put
              request = Net::HTTP::Put.new uri
            when :delete
              request = Net::HTTP::Delete.new uri
            when :get
              request = Net::HTTP::Get.new uri
            when :post
              request = Net::HTTP::Post.new uri
            when :patch
              request = Net::HTTP::Patch.new uri
            end
            request.body = data
            request['Authorization'] = "Bearer #{new_resource.access_token}"
            request['Content-Type'] = 'application/json'
            response = http.request request
          end
          response
        end
        
        # Wraps a call to the Azure REST API with retry and timeout capability.
        def azure_call_until_expected_response(method, url, data, success_codes, wait_time)
          time_elapsed = 0
          sleep_time = 2
          max_wait_time = wait_time
          success_code_found = false
          while time_elapsed < max_wait_time && !success_code_found
            response = azure_call(method, url, data)
            break if response.code.to_i >= 400
            success_code_found = success_codes.split(',').include?(response.code)
            break if success_code_found
            Chef::Log.debug("awaiting success code (#{success_codes}) (got: #{response.code}) - timeout in #{(max_wait_time - time_elapsed)} seconds.")
            sleep(sleep_time)
            time_elapsed += sleep_time
          end
          Chef::Log.debug("response code: #{response.code} body: #{response.body}")
          response
        end
      end
    end
  end
end
