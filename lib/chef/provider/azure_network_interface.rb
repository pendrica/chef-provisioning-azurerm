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
            create_or_update_network_interface # are create and update different (and should they be??)
          end
        else
          converge_by("create network interface #{new_resource.name}") do
            create_or_update_network_interface
          end
        end
      end

      action :destroy do
        converge_by("destroy network interface: #{new_resource.name}") do
          if does_network_interface_exist
            destroy_network_interface
          else
            action_handler.report_progress "network interface #{new_resource.name} was not found."
          end
        end
      end



      def does_network_interface_exist
        begin
          network_interface_list = network_management_client.network_interfaces.list(new_resource.resource_group).value!
        rescue MsRestAzure::AzureOperationError => operation_error
          error = operation_error.body['error']
          Chef::Log.error "ERROR enumerating Network interfaces:  #{error}"
          raise operation_error
        end

        network_interface_list.body.value.each do |network_interface|
          return true if network_interface.name == new_resource.name
        end
        false
      end

      def destroy_network_interface
        action_handler.report_progress 'Destroying network interface...'
        begin
          result = network_management_client.network_interfaces.delete(new_resource.resource_group, new_resource.name).value!
          Chef::Log.debug(result)
        rescue MsRestAzure::AzureOperationError => operation_error
          error = operation_error.body['error']
          Chef::Log.error "ERROR destroying network interface:  #{error}"
          raise operation_error
        end
      end

      def create_or_update_network_interface
        network_interface = Azure::ARM::Network::Models::NetworkInterface.new
        network_interface.name = new_resource.name
        network_interface.tags = new_resource.tags
        network_interface.location = new_resource.location

        new_resource.virtual_network_resource_group(new_resource.resource_group) unless new_resource.virtual_network_resource_group
        subnet_ref = get_subnet_ref(new_resource.virtual_network_resource_group, 
          new_resource.virtual_network,  new_resource.subnet)

        network_interface.properties = create_network_interface_properties(
          new_resource.name, new_resource.private_ip_allocation_method,
          new_resource.private_ip_address, subnet_ref, new_resource.dns_servers )

        action_handler.report_progress 'Creating or Updating network interface...'
        begin
          result = network_management_client.network_interfaces.create_or_update(new_resource.resource_group, new_resource.name, network_interface).value!
          Chef::Log.debug(result)
        rescue MsRestAzure::AzureOperationError => operation_error
          error = operation_error.body['error']
          Chef::Log.error "ERROR creating or updating network interface: #{error}"
          raise operation_error
        end
      end

      def create_network_interface_properties(interface_name, private_ip_type, private_ip, subnet_ref, dns_servers) 
        nic_properties = Azure::ARM::Network::Models::NetworkInterfacePropertiesFormat.new

        nic_properties.dns_settings = create_network_interface_dns_settings(dns_servers) if dns_servers
 
        ip_config =  create_network_interface_ip_configuration("#{interface_name}-ipconfig", private_ip_type, private_ip, subnet_ref)
        nic_properties.ip_configurations = [ ip_config ]
      
        nic_properties
      end
      
      def create_network_interface_dns_settings(dns_servers)
        dns_settings = Azure::ARM::Network::Models::NetworkInterfaceDnsSettings.new
        dns_settings.dns_servers = dns_servers
        dns_settings
      end

      def create_network_interface_ip_configuration(ipconfig_name, private_ip_type, private_ip, subnet_ref)
        ip_config = Azure::ARM::Network::Models::NetworkInterfaceIpConfiguration.new
        ip_config.name = ipconfig_name
        ip_config.properties = Azure::ARM::Network::Models::NetworkInterfaceIpConfigurationPropertiesFormat.new
        ip_config.properties.private_ipallocation_method = private_ip_type if  private_ip_type
        ip_config.properties.private_ipaddress = private_ip if private_ip

        if subnet_ref
          ip_config.properties.subnet = Azure::ARM::Network::Models::Subnet.new
          ip_config.properties.subnet.id = subnet_ref
        end
        ip_config
      end
      
      def get_subnet_ref(resource_group_name, vnet_name, subnet_name)
        [resource_group_name, vnet_name, subnet_name].each do |v|         
          return nil if v.nil? || v.empty?
        end

        begin
          promise =  network_management_client.subnets.get(resource_group_name, vnet_name, subnet_name)
          result = promise.value!
          subnet = result.body
        rescue MsRestAzure::AzureOperationError => operation_error
          error = operation_error.body['error']
          Chef::Log.error error
          raise operation_error
        end
      
        subnet.id
      
      end

    end # class AzureNetworkInterface
  end # class Provider
end # class Chef
