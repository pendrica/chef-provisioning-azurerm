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
        public_ip_address.tags = new_resource.tags

        public_ip_address_properties = Azure::ARM::Network::Models::PublicIpAddressPropertiesFormat.new
        public_ip_address_properties.public_ipallocation_method = new_resource.public_ip_allocation_method
        public_ip_address_properties.idle_timeout_in_minutes = new_resource.idle_timeout_in_minutes

        if new_resource.domain_name_label || new_resource.reverse_fqdn
          public_ip_address_properties.dns_settings = create_public_ip_dns_settings(new_resource.domain_name_label, new_resource.reverse_fqdn)
        end

        public_ip_address.properties = public_ip_address_properties

        try_azure_operation('creating or updating public ip') do
          network_management_client.public_ip_addresses.create_or_update(new_resource.resource_group, new_resource.name, public_ip_address).value!
        end
      end

      def destroy_public_ip_address
        try_azure_operation('destroyinh public ip') do
          network_management_client.public_ip_addresses.delete(new_resource.resource_group, new_resource.name).value!
        end
      end

      def create_public_ip_dns_settings(domain_name_label, reverse_fqdn)
        dns_settings = Azure::ARM::Network::Models::PublicIpAddressDnsSettings.new
        dns_settings.domain_name_label = domain_name_label
        dns_settings.reverse_fqdn = reverse_fqdn

        dns_settings
      end
    end
  end
end
