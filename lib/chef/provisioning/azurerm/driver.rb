require 'chef/provisioning/driver'

class Chef
  module Provisioning
    module AzureRM
      class Driver < Chef::Provisioning::Driver
        def self.from_url(driver_url, config)
          Driver.new(driver_url, config)
        end

        def initialize(driver_url, config)
          super
        end

        def self.canonicalize_url(driver_url, config)
          [driver_url, config]
        end

        def allocate_machine(_action_handler, _machine_spec, _machine_options)
          fail "The Azure Resource Manager does not implement the 'machine' resource. Please refer to documentation."
        end

        def ready_machine(_action_handler, _machine_spec, _machine_options)
        end

        def destroy_machine(_action_handler, _machine_spec, _machine_options)
        end
      end
    end
  end
end
