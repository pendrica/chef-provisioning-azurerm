require 'chef/resource/lwrp_base'
require 'chef/provisioning/azurerm/credentials'

class Chef
  module Provisioning
    module AzureRM
      class AzureResource < Chef::Resource::LWRPBase
        def initialize(*args)
          super
          return unless run_context
          @chef_environment = run_context.cheffish.current_environment
          @chef_server = run_context.cheffish.current_chef_server
          @driver = run_context.chef_provisioning.current_driver
          fail 'No driver set. (has it been set in your recipe using with_driver?)' unless driver
          @driver_name, @subscription_id = driver.split(':', 2)
          @access_token = Credentials.new.access_token_for_subscription(@subscription_id)
        end

        attr_accessor :driver
        attr_accessor :driver_name
        attr_accessor :access_token
        attr_accessor :subscription_id
      end
    end
  end
end
