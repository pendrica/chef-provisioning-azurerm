require 'spec_helper'

describe Chef::Resource::AzurePublicIPAddress do
  let(:resource) { Chef::Resource::AzurePublicIPAddress }

  it 'instantiates correctly with name' do
    expect(resource.new('publicIP').name).to eq('publicIP')
  end

  it 'sets the public_ip_allocation_method to dynamic when not specified' do
    expect(resource.new('publicIP').public_ip_allocation_method).to eq('dynamic')
  end

  it 'sets the public_ip_allocation_method to static' do
    my_resource = resource.new('publicIP')
    expect(my_resource.public_ip_allocation_method('static')).to eq('static')
  end

  it 'sets the public_ip_allocation_method to dynamic' do
    my_resource = resource.new('publicIP')
    expect(my_resource.public_ip_allocation_method('dynamic')).to eq('dynamic')
  end
  # it 'defaults to :create action' do
  #   expect(resource.new('resource-group').action).to eq([:create])
  # end
end
