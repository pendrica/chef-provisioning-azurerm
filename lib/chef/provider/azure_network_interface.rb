require 'chef/provisioning/azurerm/azure_provider'

class Chef
  class Provider
    class AzureNetworkInterface < Chef::Provisioning::AzureRM::AzureProvider
      provides :azure_network_interface

      def whyrun_supported?
        true
      end

      action :create do
        network_interface_exists = does_network_interface_exist
        if network_interface_exists
          converge_by("update network interface #{new_resource.name}") do
            # currently, we let ARM manage the idempotence, so crete and update are the same
            new_resource.public_ip_resource.run_action(:create)
            create_or_update_network_interface # are create and update different (and should they be??)
          end
        else
          converge_by("create network interface #{new_resource.name}") do
            new_resource.public_ip_resource.run_action(:create)
            create_or_update_network_interface
          end
        end
      end

      action :destroy do
        converge_by("destroy network interface: #{new_resource.name}") do
          if does_network_interface_exist
            destroy_network_interface
            new_resource.public_ip_resource.run_action(:destroy)
          else
            action_handler.report_progress "network interface #{new_resource.name} was not found."
          end
        end
      end

      def load_current_resource
        new_resource.public_ip_resource.location(new_resource.location)
        new_resource.public_ip_resource.resource_group(new_resource.resource_group) unless new_resource.public_ip_resource.resource_group
      end

      def does_network_interface_exist
        network_interface_list = try_azure_operation('enumerating network interfaces') do
          network_management_client.network_interfaces.list(new_resource.resource_group).value!
        end

        network_interface_list.body.value.each do |network_interface|
          return true if network_interface.name == new_resource.name
        end
        false
      end

      def destroy_network_interface
        action_handler.report_progress 'Destroying network interface...'
        try_azure_operation 'destroying network interface' do
          network_management_client.network_interfaces.delete(new_resource.resource_group, new_resource.name).value!
        end
      end

      def create_or_update_network_interface
        network_interface_params = create_network_interface_params
        action_handler.report_progress 'Creating or Updating network interface...'
        try_azure_operation 'Creating or Updating network interface' do
          network_management_client.network_interfaces.create_or_update(new_resource.resource_group, new_resource.name, network_interface_params).value!
        end
      end

      def create_network_interface_params
        network_interface = create_network_interface(new_resource.name, new_resource.tags, new_resource.location)

        new_resource.virtual_network_resource_group(new_resource.resource_group) unless new_resource.virtual_network_resource_group
        subnet_ref = get_subnet_ref(new_resource.virtual_network_resource_group,
                                    new_resource.virtual_network, new_resource.subnet)

        public_ip_ref = get_public_ip(new_resource.public_ip_resource.resource_group, new_resource.public_ip_resource.name)

        network_interface.properties = create_network_interface_properties(
          new_resource.name, new_resource.private_ip_allocation_method,
          new_resource.private_ip_address, subnet_ref, new_resource.dns_servers, public_ip_ref)

        network_interface
      end

      def create_network_interface(name, tags, location)
        network_interface = Azure::ARM::Network::Models::NetworkInterface.new
        network_interface.name = name
        network_interface.tags = tags
        network_interface.location = location

        network_interface
      end

      def create_network_interface_properties(interface_name, private_ip_type, private_ip, subnet_ref, dns_servers, public_ip_ref)
        nic_properties = Azure::ARM::Network::Models::NetworkInterfacePropertiesFormat.new

        nic_properties.dns_settings = create_network_interface_dns_settings(dns_servers) if dns_servers

        ip_config =  create_network_interface_ip_configuration("#{interface_name}-ipconfig", private_ip_type, private_ip, subnet_ref, public_ip_ref)
        nic_properties.ip_configurations = [ip_config]

        nic_properties
      end

      def create_network_interface_dns_settings(dns_servers)
        dns_settings = Azure::ARM::Network::Models::NetworkInterfaceDnsSettings.new
        dns_settings.dns_servers = dns_servers
        dns_settings
      end

      def create_network_interface_ip_configuration(ipconfig_name, private_ip_type, private_ip, subnet_ref, public_ip_ref)
        ip_config = Azure::ARM::Network::Models::NetworkInterfaceIpConfiguration.new
        ip_config.name = ipconfig_name
        ip_config.properties = Azure::ARM::Network::Models::NetworkInterfaceIpConfigurationPropertiesFormat.new
        ip_config.properties.private_ipallocation_method = private_ip_type if  private_ip_type
        ip_config.properties.private_ipaddress = private_ip if private_ip

        if subnet_ref
          ip_config.properties.subnet = Azure::ARM::Network::Models::Subnet.new
          ip_config.properties.subnet.id = subnet_ref
        end

        if public_ip_ref
          ip_config.properties.public_ipaddress = Azure::ARM::Network::Models::PublicIpAddress.new
          ip_config.properties.public_ipaddress.id =  public_ip_ref
        end

        ip_config
      end

      def get_public_ip(resource_group, resource_name)
        result =  try_azure_operation('getting public IP') do
          network_management_client.public_ip_addresses.get(resource_group, resource_name).value!
        end

        public_ip = result.body
        public_ip.id
      end

      def get_subnet_ref(resource_group_name, vnet_name, subnet_name)
        [resource_group_name, vnet_name, subnet_name].each do |v|
          return nil if v.nil? || v.empty?
        end

        result =  try_azure_operation('getting subnet') do
          network_management_client.subnets.get(resource_group_name, vnet_name, subnet_name).value!
        end
        subnet = result.body

        subnet.id
      end
    end # class AzureNetworkInterface
  end # class Provider
end # class Chef
