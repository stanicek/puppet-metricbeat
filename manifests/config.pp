class metricbeat::config {
  $metricbeat_config = {
    'metricbeat.modules' => $metricbeat::modules,
    'output'             => $metricbeat::output,
    'shipper'            => $metricbeat::shipper,
    'logging'            => $metricbeat::logging,
    'runoptions'         => $metricbeat::run_options,
  }

  case $::kernel {
    'Linux'   : {
      file {'metricbeat.yml':
        ensure  => file,
        path    => '/etc/metricbeat/metricbeat.yml',
        content => template("${module_name}/metricbeat.yml.erb"),
        owner   => 'root',
        group   => 'root',
        mode    => $metricbeat::config_file_mode,
        notify  => Service['metricbeat'],
      }
    } # end Linux

    'Windows' : {
      file {'metricbeat.yml':
        ensure  => file,
        path    => 'C:/Program Files/Metricbeat/metricbeat.yml',
        content => template("${module_name}/metricbeat.yml.erb"),
        notify  => Service['metricbeat'],
      }
    } # end Windows

    default : {
      fail($metricbeat::kernel_fail_message)
    }
  }
}
