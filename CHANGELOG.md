# chef-provisioning-azurerm Changelog

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
