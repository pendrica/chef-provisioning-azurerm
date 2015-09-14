require 'spec_helper'

describe Chef::Resource::AzureStorageAccount do
  let(:resource) { Chef::Resource::AzureStorageAccount }

  it 'instantiates correctly with name' do
    expect(resource.new('storageaccountname').name).to eq('storageaccountname')
  end

  it 'does not instantiate with an uppercase name' do
    expect(resource.new('STORAGEACCOUNTNAME').name).to eq('STORAGEACCOUNTNAME')
  end

  it 'does not instantiate when name is less than 3 characters long' do
    short_name = 2.times { 'n' }
    expect { resource.new(short_name).name }.to raise_error(Chef::Exceptions::ValidationFailed)
  end

  it 'does not instantiate when name is longer than 24 characters long' do
    long_name = 25.times { 'n' }
    expect { resource.new(long_name).name }.to raise_error(Chef::Exceptions::ValidationFailed)
  end

  it 'does not instantiate when name contains non-alphanumeric characters' do
    expect { resource.new('s-t-o-r-a-g-e').name }.to raise_error(Chef::Exceptions::ValidationFailed)
  end

  it 'does not set a custom domain when none is provided' do
    expect(resource.new('storageaccountname').custom_domain).to eq(nil)
  end
end
