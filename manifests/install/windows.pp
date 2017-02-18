class metricbeat::install::windows {
  $filename = regsubst($metricbeat::download_url, '^https.*\/([^\/]+)\.[^.].*', '\1')
  $foldername = 'Metricbeat'

  file { $metricbeat::tmp_dir:
    ensure => directory
  }

  file { $metricbeat::install_dir:
    ensure => directory
  }

  remote_file {"${metricbeat::tmp_dir}/${filename}.zip":
    ensure      => present,
    source      => $metricbeat::download_url,
    require     => File[$metricbeat::tmp_dir],
    verify_peer => false,
  }

  exec { "unzip ${filename}":
    command  => "\$sh=New-Object -COM Shell.Application;\$sh.namespace((Convert-Path '${metricbeat::install_dir}')).Copyhere(\$sh.namespace((Convert-Path '${metricbeat::tmp_dir}/${filename}.zip')).items(), 16)",
    creates  => "${metricbeat::install_dir}/Metricbeat",
    provider => powershell,
    require  => [
      File[$metricbeat::install_dir],
      Remote_file["${metricbeat::tmp_dir}/${filename}.zip"],
    ],
  }

  exec { 'rename folder':
    command  => "Rename-Item '${metricbeat::install_dir}/${filename}' Metricbeat",
    creates  => "${metricbeat::install_dir}/Metricbeat",
    provider => powershell,
    require  => Exec["unzip ${filename}"],
  }

  exec { "install ${filename}":
    cwd      => "${metricbeat::install_dir}/Metricbeat",
    command  => './install-service-metricbeat.ps1',
    onlyif   => 'if(Get-WmiObject -Class Win32_Service -Filter "Name=\'metricbeat\'") { exit 1 } else {exit 0 }',
    provider =>  powershell,
    require  => Exec['rename folder'],
  }
}
