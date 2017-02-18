class metricbeat::service {
  service { 'metricbeat':
    ensure => $metricbeat::service_ensure,
    enable => $metricbeat::service_enable,
  }
}
