# puppet-metricbeat

[![Build Status](https://travis-ci.org/stanicek/puppet-metricbeat.svg?branch=master)](https://travis-ci.org/pcfens/puppet-metricbeat)

#### Table of Contents

1. [Description](#description)
2. [Setup - The basics of getting started with metricbeat](#setup)
    - [What metricbeat affects](#what-metricbeat-affects)
    - [Setup requirements](#setup-requirements)
    - [Beginning with metricbeat](#beginning-with-metricbeat)
3. [Usage - Configuration options and additional functionality](#usage)
4. [Reference](#reference)
    - [Public Classes](#public-classes)
    - [Private Classes](#private-classes)
    - [Public Defines](#public-defines)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Description

The `metricbeat` module installs and configures
[metricbeat](https://www.elastic.co/products/beats/metricbeat) to ship system performance
information to elasticsearch, logstash, or anything else that accepts the beats
protocol.

## Setup

### What metricbeat affects

By default `metricbeat` adds a software repository to your system, and installs metricbeat along
with required configurations.

### Setup Requirements

The `metricbeat` module depends on [`puppetlabs/stdlib`](https://forge.puppetlabs.com/puppetlabs/stdlib), and on
[`puppetlabs/apt`](https://forge.puppetlabs.com/puppetlabs/apt) on Debian based systems.

### Beginning with metricbeat

`metricbeat` can be installed with `puppet module install pcfens-metricbeat` (or with r10k, librarian-puppet, etc.)

By default, metricbeat ships system statistics (system load, cpu usage, swap usage, and memory usage),
per-process statistics, and disk mounts/usage.

## Usage

All of the default values in metricbeat follow the upstream defaults (at the time of writing).

To ship system stats to [elasticsearch](https://www.elastic.co/guide/en/beats/metricbeat/current/metricbeat-configuration-options.html#elasticsearch-output):
```puppet
class { 'metricbeat':
  output => {
    'elasticsearch' => {
     'hosts' => [
       'http://localhost:9200',
       'http://anotherserver:9200'
     ],
     'index'       => 'metricbeat',
     'cas'         => [
        '/etc/pki/root/ca.pem',
     ],
    },
  },
}

```

To ship system stats through [logstash](https://www.elastic.co/guide/en/beats/metricbeat/current/metricbeat-configuration-options.html#logstash-output):
```puppet
class { 'metricbeat':
  output => {
    'logstash'     => {
     'hosts' => [
       'localhost:5044',
       'anotherserver:5044'
     ],
     'loadbalance' => true,
    },
  },
}

```

[Shipper](https://www.elastic.co/guide/en/beats/metricbeat/current/metricbeat-configuration-options.html#configuration-shipper) and [logging](https://www.elastic.co/guide/en/beats/metricbeat/current/metricbeat-configuration-options.html#configuration-logging) options can be configured the same way, and are documented on the [elastic website](https://www.elastic.co/guide/en/beats/metricbeat/current/_overview.html).

### Configuring Inputs

By default, metricbeat ships everything that it can, but can be tuned to ship specific
information.

The full default hash looks like
```puppet
{
  period => 10,   # How often stats should be collected and sent, in seconds.
  procs  => [     # An array of what processes to send more detailed information on.
    '.*',
  ]
  stats  => {
    system     => true,   # Whether or not to ship system-wide information
    proc       => true,   # Whether or not individual process information should be shipped
    filesystem => true,   # Whether or not filesystem/disk information should be shipped
  }
}
```

Each component is documented more fully in the
[metricbeat documentation](https://www.elastic.co/guide/en/beats/metricbeat/current/metricbeat-configuration-options.html#configuration-input).

## Reference
 - [**Public Classes**](#public-classes)
    - [Class: metricbeat](#class-metricbeat)
 - [**Private Classes**](#private-classes)
    - [Class: metricbeat::config](#class-metricbeatconfig)
    - [Class: metricbeat::install](#class-metricbeatinstall)
    - [Class: metricbeat::params](#class-metricbeatparams)
    - [Class: metricbeat::repo](#class-metricbeatrepo)
    - [Class: metricbeat::service](#class-metricbeatservice)
    - [Class: metricbeat::install::linux](#class-metricbeatinstalllinux)
    - [Class: metricbeat::install::windows](#class-metricbeatinstallwindows)

### Public Classes

#### Class: `metricbeat`

Installs and configures metricbeat.

**Parameters within `metricbeat`**
- `package_ensure`: [String] The ensure parameter for the metricbeat package (default: present)
- `manage_repo`: [Boolean] Whether or not the upstream (elastic) repo should be configured or not (default: true)
- `service_ensure`: [String] The ensure parameter on the metricbeat service (default: running)
- `service_enable`: [String] The enable parameter on the metricbeat service (default: true)
- `config_file_mode`: [String] The permissions mode set on configuration files (default: 0644)
- `input`: [Hash] Will be converted to YAML for the input section of the configuration file (see documentation, and above)(default: {})
- `output`: [Hash] Will be converted to YAML for the required output section of the configuration (see documentation, and above)
- `shipper`: [Hash] Will be converted to YAML to create the optional shipper section of the metricbeat config (see documentation)
- `logging`: [Hash] Will be converted to YAML to create the optional logging section of the metricbeat config (see documentation)
- `conf_template`: [String] The configuration template to use to generate the main metricbeat.yml config file
- `download_url`: [String] The URL of the zip file that should be downloaded to install metricbeat (windows only)
- `install_dir`: [String] Where metricbeat should be installed (windows only)
- `tmp_dir`: [String] Where metricbeat should be temporarily downloaded to so it can be installed (windows only)
- `prospectors`: [Hash] Prospectors that will be created. Commonly used to create prospectors using hiera

### Private Classes

#### Class: `metricbeat::config`

Creates the configuration files required for metricbeat (but not the prospectors)

#### Class: `metricbeat::install`

Calls the correct installer class based on the kernel fact.

#### Class: `metricbeat::params`

Sets default parameters for `metricbeat` based on the OS and other facts.

#### Class: `metricbeat::repo`

Installs the yum or apt repository for the system package manager to install metricbeat.

#### Class: `metricbeat::service`

Configures and manages the metricbeat service.

#### Class: `metricbeat::install::linux`

Install the metricbeat package on Linux kernels.

#### Class: `metricbeat::install::windows`

Downloads, extracts, and installs the metricbeat zip file in Windows.


## Limitations

This module doesn't load the [elasticsearch index template](https://www.elastic.co/guide/en/beats/metricbeat/current/metricbeat-getting-started.html#metricbeat-template)
into elasticsearch (required when shipping directly to elasticsearch).

## Development

Pull requests and bug reports are welcome. If you're sending a pull request, please consider
writing tests if applicable.
