require 'spec_helper'

describe Chef::Resource::AzureResourceTemplate do
  let(:resource) { Chef::Resource::AzureResourceTemplate }

  it 'instantiates correctly with name' do
    expect(resource.new('deployment-template-name').name).to eq('deployment-template-name')
  end

  it 'defaults to :deploy action' do
    expect(resource.new('deployment').action).to eq(:deploy)
  end
end
