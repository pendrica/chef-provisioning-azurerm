require 'spec_helper'

describe Chef::Resource::AzureNetworkInterface do
  let(:resource) { Chef::Resource::AzureNetworkInterface }

  it 'instantiates correctly with name' do
    expect(resource.new('interface').name).to eq('interface')
  end

  it 'sets the location to west us when not specified' do
    expect(resource.new('interface').location).to eq('westus')
  end

  it 'sets the location' do
    my_resource = resource.new('interface')
    expect(my_resource.location('eastus2')).to eq('eastus2')
  end

  # it 'defaults to :create action' do
  #   expect(resource.new('interface').action).to eq([:create]) || eq(:create)
  # end

  it 'raises an error when resource group is longer than 80 characters long' do
    eighty_one_character_name = 'n' * 81
    expect { resource.new(eighty_one_character_name).name }.to raise_error(Chef::Exceptions::ValidationFailed)
  end

  it 'raises an error when resource group contains invalid characters' do
    name_with_invalid_char = 'resource!@£$%^&*'
    expect { resource.new(name_with_invalid_char).name }.to raise_error(Chef::Exceptions::ValidationFailed)
  end

  it 'correctly sets dns servers when properly formatted' do
    my_resource = resource.new('interface')
    expect(my_resource.dns_servers(['10.0.0.1', '10.0.0.2'])).to contain_exactly('10.0.0.1', '10.0.0.2')
  end

  it 'raises an error when non-ip addresses are passed to dns_servers' do
    my_resource = resource.new('interface')
    expect { my_resource.dns_servers(['test']) }.to raise_error(Chef::Exceptions::ValidationFailed)
  end

  it 'raises an error when invalid ip addresses are passed to dns_servers' do
    my_resource = resource.new('interface')
    expect { my_resource.dns_servers(['300.0.0.1']) }.to raise_error(Chef::Exceptions::ValidationFailed)
  end

  it 'correctly sets private_ip_address when properly formatted' do
    my_resource = resource.new('interface')
    expect(my_resource.private_ip_address('10.0.0.1')).to eq('10.0.0.1')
  end

  it 'raises an error when non-ip addresses are passed to private_ip_address' do
    my_resource = resource.new('interface')
    expect { my_resource.private_ip_address('test') }.to raise_error(Chef::Exceptions::ValidationFailed)
  end

  it 'raises an error when invalid ip addresses are passed to private_ip_address' do
    my_resource = resource.new('interface')
    expect { my_resource.private_ip_address('300.0.0.1') }.to raise_error(Chef::Exceptions::ValidationFailed)
  end

  it 'sets the private_ip_allocation_method to dynamic when not specified' do
    expect(resource.new('interface').private_ip_allocation_method).to eq('dynamic')
  end

  it 'sets the private_ip_allocation_method to static' do
    my_resource = resource.new('interface')
    expect(my_resource.private_ip_allocation_method('static')).to eq('static')
  end

  it 'sets the private_ip_allocation_method to dynamic' do
    my_resource = resource.new('interface')
    expect(my_resource.private_ip_allocation_method('dynamic')).to eq('dynamic')
  end

  it 'raises an error when invalid private_ip_allocation_method is passed' do
    my_resource = resource.new('interface')
    expect { my_resource.private_ip_allocation_method('INVALID') }.to raise_error(Chef::Exceptions::ValidationFailed)
  end
end
