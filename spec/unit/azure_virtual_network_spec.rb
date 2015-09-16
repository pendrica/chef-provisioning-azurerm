require 'spec_helper'

describe Chef::Resource::AzureVirtualNetwork do
  let(:resource) { Chef::Resource::AzureVirtualNetwork }

  it 'instantiates correctly with name' do
    expect(resource.new('virtualnetwork').name).to eq('virtualnetwork')
  end

  
end
