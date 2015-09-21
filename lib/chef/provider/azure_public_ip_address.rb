require 'chef/provisioning/azurerm/azure_provider'

class Chef
  class Provider
    class AzurePublicIPAddress < Chef::Provisioning::AzureRM::AzureProvider
      provides :azure_public_ip_address

      def whyrun_supported?
        true
      end

      action :create do
        converge_by("create or update public IP address #{new_resource.name}") do
          create_public_ip_address
        end
      end

      action :destroy do
        converge_by("destroy public IP address #{new_resource.name}") do
          if public_ip_address_exists
            destroy_public_ip_address
          else
            action_handler.report_progress "public IP address #{new_resource.name} was not found."
          end
        end
      end
  
      def public_ip_address_exists
        public_ip_address_list = network_management_client.public_ip_addresses.list(new_resource.resource_group).value!
        public_ip_address_list.body.value.each do |public_ip_address|
          return true if public_ip_address.name == new_resource.name
        end
        false
      end

      def create_public_ip_address
        public_ip_address = Azure::ARM::Network::Models::PublicIpAddress.new
        public_ip_address.location = new_resource.location
        public_ip_address_properties = Azure::ARM::Network::Models::PublicIpAddressPropertiesFormat.new
        public_ip_address_properties.public_ipallocation_method = new_resource.public_ip_allocation_method
        # TODO: Deal with Static allocation, i.e.:
        # public_ip_address_properties.dns_settings = [DNSSettings type]
        # public_ip_address_properties.idle_timeout_in_minutes = new_resource.idle_timeout_in_minutes
        public_ip_address.properties = public_ip_address_properties
      
        begin
          result = network_management_client.public_ip_addresses.create_or_update(new_resource.resource_group, new_resource.name, public_ip_address).value!
          Chef::Log.debug(result)
        rescue MsRestAzure::AzureOperationError => operation_error
          error = operation_error.body['error']
          Chef::Log.error "#{error}"
          raise operation_error
        end
      end
      
      def destroy_public_ip_address
        begin
          result = network_management_client.public_ip_addresses.delete(new_resource.resource_group, new_resource.name).value!
          Chef::Log.debug(result)
        rescue MsRestAzure::AzureOperationError => operation_error
          error = operation_error.body['error']
          Chef::Log.error "#{error}"
          raise operation_error
        end
      end
    end
  end
end
