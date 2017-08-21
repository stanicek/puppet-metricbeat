# This class installs the Elastic metricbeat tool/service
#
# @example
# class { 'metricbeat':
#   input   => {
#     period => '15',
#     procs  => ['.*'],
#     stats  => {
#       system     => true,
#       proc       => false,
#       filesystem => true,
#     },
#   },
#   outputs => {
#     'logstash' => {
#       'hosts' => [
#         'localhost:5044',
#       ],
#     },
#   },
# }
#
# @param package_ensure [String] The ensure parameter for the metricbeat package (default: present)
# @param manage_repo [Boolean] Whether or not the upstream (elastic) repo should be configured or not (default: true)
# @param service_ensure [String] The ensure parameter on the metricbeat service (default: running)
# @param service_enable [String] The enable parameter on the metricbeat service (default: true)
# @param config_file_mode [String] The unix permissions mode set on configuration files (default: 0644)
# @param input [Hash] Will be converted to YAML for the input section of the configuration file (see documentation)(default: {})
# @param output [Hash] Will be converted to YAML for the required outputs section of the configuration (see documentation, and above)
# @param shipper [Hash] Will be converted to YAML to create the optional shipper section of the metricbeat config (see documentation)
# @param logging [Hash] Will be converted to YAML to create the optional logging section of the metricbeat config (see documentation)
# @param conf_template [String] The configuration template to use to generate the main metricbeat.yml config file
# @param download_url [String] The URL of the zip file that should be downloaded to install metricbeat (windows only)
# @param install_dir [String] Where metricbeat should be installed (windows only)
# @param tmp_dir [String] Where metricbeat should be temporarily downloaded to so it can be installed (windows only)
class metricbeat (
  $package_ensure   = $metricbeat::params::package_ensure,
  $manage_repo      = $metricbeat::params::manage_repo,
  $service_ensure   = $metricbeat::params::service_ensure,
  $service_enable   = $metricbeat::params::service_enable,
  $config_file_mode = $metricbeat::params::config_file_mode,
  $modules          = $metricbeat::params::modules,
  $output           = $metricbeat::params::output,
  $shipper          = $metricbeat::params::shipper,
  $logging          = $metricbeat::params::logging,
  $run_options      = $metricbeat::params::run_options,
  $conf_template    = $metricbeat::params::conf_template,
  $download_url     = $metricbeat::params::download_url,
  $install_dir      = $metricbeat::params::install_dir,
  $tmp_dir          = $metricbeat::params::tmp_dir,
) inherits metricbeat::params {

  $kernel_fail_message = "${::kernel} is not supported by metricbeat."

  validate_bool($manage_repo)
  validate_array($modules)
  validate_hash($output, $logging, $run_options)
  validate_string($package_ensure, $service_ensure, $config_file_mode, $conf_template)
  validate_string($download_url, $install_dir, $tmp_dir)

  if $package_ensure == '1.0.0-beta4' or $package_ensure == '1.0.0-rc1' {
    fail('Metricbeat versions 1.0.0-rc1 and before are unsupported because they don\'t parse normal YAML headers')
  }

  anchor { 'metricbeat::begin': } ->
  class { 'metricbeat::install': } ->
  class { 'metricbeat::config': } ->
  class { 'metricbeat::service': } ->
  anchor { 'metricbeat::end': }
}
