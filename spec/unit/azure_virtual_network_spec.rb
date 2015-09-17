require 'spec_helper'

describe Chef::Resource::AzureVirtualNetwork do
  let(:resource) { Chef::Resource::AzureVirtualNetwork }

  it 'instantiates correctly with name' do
    expect(resource.new('virtualnetwork').name).to eq('virtualnetwork')
  end

  # it 'defaults to :create action' do
  #   expect(resource.new('virtualnetwork').action).to eq([:create]) || eq(:create)
  # end

  it 'correctly sets dns servers when properly formatted' do
    my_vnet_resource = resource.new('virtualnetwork')
    expect(my_vnet_resource.dns_servers(['10.0.0.1', '10.0.0.2'])).to contain_exactly('10.0.0.1', '10.0.0.2')
  end

  it 'raises an error when non-ip addresses are passed to dns_servers' do
    my_vnet_resource = resource.new('virtualnetwork')
    expect { my_vnet_resource.dns_servers(['test']) }.to raise_error(Chef::Exceptions::ValidationFailed)
  end

  it 'raises an error when invalid ip addresses are passed to dns_servers' do
    my_vnet_resource = resource.new('virtualnetwork')
    expect { my_vnet_resource.dns_servers(['300.0.0.1']) }.to raise_error(Chef::Exceptions::ValidationFailed)
  end

  it 'correctly sets address_prefixes when properly formatted' do
    my_vnet_resource = resource.new('virtualnetwork')
    expect(my_vnet_resource.address_prefixes(['192.168.0.0/24', '10.0.0.0/16'])).to contain_exactly('192.168.0.0/24', '10.0.0.0/16')
  end

  it 'raises an error when non-ip addresses are passed to address_prefixes' do
    my_vnet_resource = resource.new('virtualnetwork')
    expect { my_vnet_resource.address_prefixes(['test']) }.to raise_error(Chef::Exceptions::ValidationFailed)
  end

  it 'raises an error when invalid ip addresses are passed to address_prefixes' do
    my_vnet_resource = resource.new('virtualnetwork')
    expect { my_vnet_resource.address_prefixes(['300.0.0.1']) }.to raise_error(Chef::Exceptions::ValidationFailed)
  end

  it 'raises an error when invalid CIDR sizes are passed to address_prefixes' do
    my_vnet_resource = resource.new('virtualnetwork')
    expect { my_vnet_resource.address_prefixes(['100.0.0.1/24', '10.0.0.0/33']) }.to raise_error(Chef::Exceptions::ValidationFailed)
  end

  it 'correctly sets subnets when properly formatted' do
    my_vnet_resource = resource.new('virtualnetwork')
    expect(my_vnet_resource.subnets([{ name: 'web', address_prefix: '192.168.0.0/24' }, { name: 'db', address_prefix: '10.0.0.0/16' }])).to contain_exactly({ name: 'web', address_prefix: '192.168.0.0/24' },  name: 'db', address_prefix: '10.0.0.0/16')
  end

  it 'raises an error when subnets dont contain :name and :address_prefix' do
    my_vnet_resource = resource.new('virtualnetwork')
    expect { my_vnet_resource.subnets([{ not_name: 'web', address_prefix: '192.168.0.0/24' }, { name: 'db', address_prefix: '10.0.0.0/16' }]) }.to raise_error(Chef::Exceptions::ValidationFailed)
  end
end
