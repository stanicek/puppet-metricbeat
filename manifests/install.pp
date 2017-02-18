class metricbeat::install {
  case $::kernel {
    'Linux':   {
      contain metricbeat::install::linux
      if $::metricbeat::manage_repo {
        contain metricbeat::repo
        Class['metricbeat::repo'] -> Class['metricbeat::install::linux']
      }
    }
    'Windows': {
      contain metricbeat::install::windows
    }
    default:   {
      fail($metricbeat::kernel_fail_message)
    }
  }
}
