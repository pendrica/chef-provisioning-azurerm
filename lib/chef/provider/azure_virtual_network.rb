require 'chef/provisioning/azurerm/azure_provider'

class Chef
  class Provider
    class AzureVirtualNetwork < Chef::Provisioning::AzureRM::AzureProvider
      provides :azure_virtual_network

      def whyrun_supported?
        true
      end

      action :create do
        virtual_network_exists = does_virtual_network_exist

        if virtual_network_exists
          converge_by("update virtual network #{new_resource.name}") do
            # currently, we let ARM manage the idempotence, so crete and update are the same
            create_or_update_virtual_network # are create and update different (and should they be??)
          end
        else
          converge_by("create virtual network #{new_resource.name}") do
            create_or_update_virtual_network
          end
        end
      end

      action :destroy do
        converge_by("destroy virtual network: #{new_resource.name}") do
          if does_virtual_network_exist
            destroy_virtual_network
          else
            action_handler.report_progress "virtual network #{new_resource.name} was not found."
          end
        end
      end

      def does_virtual_network_exist
        virtual_network_list = try_azure_operation('listing virtual networks') do
          network_management_client.virtual_networks.list(new_resource.resource_group).value!
        end

        virtual_network_list.body.value.each do |virtual_network|
          return true if virtual_network.name == new_resource.name
        end
        false
      end

      def destroy_virtual_network
        action_handler.report_progress 'Destroying Virtual Network...'
        try_azure_operation('destroying virtual network') do
          network_management_client.virtual_networks.delete(new_resource.resource_group, new_resource.name).value!
        end
      end

      def create_or_update_virtual_network
        virtual_network = Azure::ARM::Network::Models::VirtualNetwork.new

        virtual_network.tags = new_resource.tags
        virtual_network.location = new_resource.location

        virtual_network.properties = create_virtual_network_properties(
          new_resource.address_prefixes, new_resource.subnets, new_resource.dns_servers)

        action_handler.report_progress 'Creating or Updating Virtual Network...'

        try_azure_operation('creating or updating network interface') do
          network_management_client.virtual_networks.create_or_update(new_resource.resource_group, new_resource.name, virtual_network).value!
        end
      end

      def create_virtual_network_properties(address_prefixes, subnets, dns_servers)
        props = Azure::ARM::Network::Models::VirtualNetworkPropertiesFormat.new

        props.address_space = Azure::ARM::Network::Models::AddressSpace.new
        props.address_space.address_prefixes = address_prefixes

        if dns_servers
          props.dhcp_options = Azure::ARM::Network::Models::DhcpOptions.new
          props.dhcp_options.dns_servers = dns_servers
        end

        props.subnets = []
        subnets.each do |subnet|
          props.subnets.push(create_subnet(subnet[:name], subnet[:address_prefix]))
        end

        props
      end

      def create_subnet(subnet_name, subnet_address)
        subnet = Azure::ARM::Network::Models::Subnet.new
        subnet.name = subnet_name
        subnet.properties = Azure::ARM::Network::Models::SubnetPropertiesFormat.new
        subnet.properties.address_prefix = subnet_address

        subnet
      end
    end # class AzureVirtualNetwork
  end # class Provider
end # class Chef
