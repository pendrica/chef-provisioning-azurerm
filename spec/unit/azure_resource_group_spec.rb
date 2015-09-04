require 'spec_helper'

describe Chef::Resource::AzureResourceGroup do
  let(:resource) { Chef::Resource::AzureResourceGroup }

  it 'instantiates correctly with name' do
    expect(resource.new('resource-group-name').name).to eq('resource-group-name')
  end

  it 'defaults to :create action' do
    expect(resource.new('resource-group').action).to eq(:create)
  end

  it 'does not instantiate when name is longer than 80 characters long' do
    eighty_one_character_name = 81.times { 'n' }
    expect { resource.new(eighty_one_character_name).name }.to raise_error(Chef::Exceptions::ValidationFailed)
  end

  it 'does not instantiate when name contains invalid characters' do
    name_with_invalid_char = 'resource!@£$%^&*'
    expect { resource.new(name_with_invalid_char).name }.to raise_error(Chef::Exceptions::ValidationFailed)
  end

  it 'does not instantiate when name ends with a period' do
    name_ending_period = 'resource.'
    expect { resource.new(name_ending_period).name }.to raise_error(Chef::Exceptions::ValidationFailed)
  end

  it 'selects a default location when none is provided' do
    expect(resource.new('resource-template-name').location).to eq('westus')
  end
end
