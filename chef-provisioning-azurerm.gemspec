# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'chef/provisioning/azurerm/version'

Gem::Specification.new do |spec|
  spec.name          = 'chef-provisioning-azurerm'
  spec.version       = Chef::Provisioning::AzureRM::VERSION
  spec.authors       = ['Stuart Preston']
  spec.email         = ['stuart@pendrica.com']
  spec.summary       = 'Chef Provisioner for the Azure Resource Management (ARM) REST API.'
  spec.description   = 'Chef Provisioner for the Microsoft Azure Resource Management API.'
  spec.homepage      = 'https://github.com/pendrica/chef-provisioning-azurerm'
  spec.license       = 'Apache-2.0'

  spec.files         = Dir['LICENSE.txt', 'README.md', 'CHANGELOG.md', 'lib/**/*']
  spec.require_paths = ['lib']

  spec.add_dependency 'chef', '~> 12', '< 13.0.0'
  spec.add_dependency 'chef-provisioning', '~> 2.0', '< 2.3.0'
  spec.add_dependency 'azure_mgmt_resources', '~> 0.5', '>= 0.5.0'
  spec.add_dependency 'azure_mgmt_storage', '~> 0.5', '>= 0.5.0'
  spec.add_dependency 'azure_mgmt_compute', '~> 0.5', '>= 0.5.0'
  spec.add_dependency 'azure_mgmt_network', '~> 0.5', '>= 0.5.0'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
end
