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

  spec.files         = Dir['LICENSE.txt', 'README.md', 'lib/**/*']
  spec.require_paths = ['lib']

  spec.add_dependency 'chef', '~> 12.0'
  spec.add_dependency 'chef-provisioning', '~> 1.0'
  spec.add_dependency 'json', '~> 1.8', '>= 1.8.2'
  spec.add_dependency 'inifile', '~> 2.0'

  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'rake', '~> 10.0'
end
