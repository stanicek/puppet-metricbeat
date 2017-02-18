require 'spec_helper'

describe 'metricbeat', :type => :class do
  let :facts do
    {
      :kernel => 'Linux',
      :osfamily => 'Debian',
      :lsbdistid => 'Ubuntu',
    }
  end

  context 'defaults' do
    it { is_expected.to contain_metricbeat__params }
    it { is_expected.to contain_package('metricbeat') }
    it { is_expected.to contain_file('metricbeat.yml').with(
      :path => '/etc/metricbeat/metricbeat.yml',
      :mode => '0644',
    )}
    it { is_expected.to contain_service('metricbeat').with(
      :enable => true,
      :ensure => 'running',
    )}
    it { is_expected.to contain_apt__source('beats').with(
      :location => 'http://packages.elastic.co/beats/apt',
      :key      => {
        'id'     => '46095ACC8548582C1A2699A9D27D666CD88E42B4',
        'source' => 'http://packages.elastic.co/GPG-KEY-elasticsearch',
      }
    )}
  end

  describe 'on a RHEL system' do
    let :facts do
      {
        :kernel => 'Linux',
        :osfamily => 'RedHat',
      }
    end

    it { is_expected.to contain_yumrepo('beats').with(
      :baseurl => 'https://packages.elastic.co/beats/yum/el/$basearch',
      :gpgkey  => 'http://packages.elastic.co/GPG-KEY-elasticsearch',
    ) }
  end

  describe 'on a Windows system' do
    let :facts do
      {
        :kernel => 'Windows',
      }
    end

    it { is_expected.to contain_file('metricbeat.yml').with(
      :path => 'C:/Program Files/Metricbeat/metricbeat.yml',
    )}
  end


  describe 'on a Solaris system' do
    let :facts do
      {
        :osfamily => 'Solaris',
      }
    end
    context 'it should fail as unsupported' do
      it { expect { should raise_error(Puppet::Error) } }
    end
  end
end
