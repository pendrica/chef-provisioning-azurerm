# chef-provisioning-azurerm Changelog

## [0.6.1] - 2017-11-28
- Fixing dependencies on Azure SDK (resolves breaking change)

## [0.6.0] - 2017-07-24
- Relaxing the Chef dependency to support Chef 12 and 13 (@stuartpreston)
- Pinning to latest Azure SDK, fixing breaking changes (@stuartpreston)

## [0.5.0] - 2017-04-29
- Support for AzureUSGovernment, AzureChina and AzureGermanyCloud environments (@stuartpreston)

## [0.4.0] - 2016-10-02
- BREAKING CHANGE: No longer assume ARM template_source points to a location within the Chef Repo, users must now specify the complete path to the file (@stuartpreston)
- Removing gem dependency on json, chef-provisioning in attempt to maintain compat with <2.0 versions (@stuartpreston)
- Align with latest Azure SDK for Ruby (@stuartpreston)
- AzureOperationError no longer has a body property (@stuartpreston)
- Add custom_domain property to fix Storage resource (@bgxavier)
- Chef VM Extension now supports chef_environment property (@andrimarjonsson)

## [0.3.5] - 2016-05-10
- Removing gem dependency on inifile, assume chef-provisioning has this covered (@stuartpreston)

## [0.3.4] - 2016-03-07
- Pin driver at known versions of ms_rest_azure to fix a forward compatibility issue (@stuartpreston)

## [0.3.3] - 2016-01-25
- Raise AzureOperationError into log (@stuartpreston) 
- Fix#6 VM extension JSON not formatted correctly (@andrewelizondo)

## [0.3.2] - 2015-10-07
### Changed
- References to Azure SDK updated, supports Linux
- Adding more resources

## [0.3.1] - 2015-09-05
### Changed
- :destroy action on azure_resource_group now correctly detects existence of resource group before attempting deletion

## [0.3.0] - 2015-09-04
### Changed
- Now using ARM functionality from the updated [Azure SDK for Ruby](http://github.com/azure/azure-sdk-for-ruby) rather than direct HTTPS calls to the Resource Manager API.
- **BREAKING CHANGE** Authentication to Azure must now be via Service Principal, not username and password as previous.  See the [README.md](https://github.com/pendrica/chef-provisioning-azurerm) for more details.

## [0.2.14] - 2015-08-21
### Changed
- Minimize logging to info, favour action_handler.report_progress

## [0.2.13] - 2015-08-20
### Changed
- chef_extension parameters are now required if the Chef VM Extension is to be added to compute resources.
- Updated README to include explanation of valid chef_extension parameters

## [0.2.12] - 2015-08-13
### Added
- Updated examples and README
- Rubocop compliance
