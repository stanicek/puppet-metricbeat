class metricbeat::install::linux {
  package {'metricbeat':
    ensure => $metricbeat::package_ensure,
  }
}
