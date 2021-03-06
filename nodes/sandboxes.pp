node /sandbox[0-9]+.*/{

  case $hostname {
    'sandbox01':{
      include jenkins
      jenkins::plugin {
        'swarm': ;
        'git':   ;
        'credentials':   ;
        'ldap':   ;
        'ssh-slaves':   ;
        'stackhammer':   ;
        'devstack':   ;
        'nodelabelparameter': ;
        'parameterized-trigger': ;
      }
      package {'fpm':
        ensure => installed,
        provider => 'gem',
      }
      $jenkinsconfig_path = '/var/lib/jenkins/'
#      class {'jenkins_job_builder':}
      file { "${jenkinsconfig_path}users":
        ensure  => directory,
        source  => "puppet:///extra_files/jenkins/users",
        recurse => remote,
        replace => false,
        purge   => false,
        owner   => 'jenkins',
      }
      file { "${jenkinsconfig_path}config.xml":
        ensure  => file,
        source  => "${jenkinsconfig_path}users/config_base.xml",
        replace => false,
        require => File["${jenkinsconfig_path}users"],
        owner   => 'jenkins',
      }
    }
    #'sandbox02':{
      #class {'windows_common':}
      #class {'windows_common::configuration::disable_firewalls':}
      #class {'windows_common::configuration::enable_auto_update':}
      #class {'windows_common::configuration::ntp':
       # before => Class['windows_openssl'],
      #}
      #class {'windows_common::configuration::rdp':}
      #class {'windows_openssl': }
      #class {'java': distribution => 'jre' }
      #class {'jenkins_test::slave':
        #install_java      => false,
        #require           => [Class['java']],
        #manage_slave_user => false,
        #executors         => 1,
        #labels            => 'hv',
       # masterurl         => 'http://sandbox01.openstack.tld:8080',
      #}

      #class{'windows_sensu':
       # rabbitmq_password        => 'sensu',
      #  rabbitmq_host            => "10.21.7.4",
     # }
     #
    #}
    'sandbox-000-kvm':{
      class{'basenode':}
      class{'dell_openmanage':}
      class{'sensu_server::client':}
      class{'jenkins::slave':
        labels            => 'kvm',
        masterurl         => 'http://sandbox01.openstack.tld:8080',
      }
#      class {'packstack':
#        openstack_release => 'havana',
#        controller_host   => '10.21.7.41',
#        network_host      => '10.21.7.42',
#        kvm_compute_host  => '10.21.7.31,10.21.7.32,10.21.7.33,10.21.7.34,10.21.7.35,10.21.7.36,10.21.7.38',
#      }
#      case $hostname {
#        'kvm-compute01','kvm-compute02','kvm-compute03','kvm-compute04','kvm-compute05','kvm-compute06':{ $data_interface = 'em2' }
#        'kvm-compute07','kvm-compute08','kvm-compute09','kvm-compute10':{ 
          $data_interface = 'eth1' 
#        }
#        default: { notify {"This isn't for ${hostname}":}
#        }
#      }
#      case $hostname {
#        'kvm-compute08','kvm-compute09','kvm-compute10':{
           file {'/etc/nova':
           ensure  => directory,
           recurse => true,
           owner   => 'root',
           group   => 'root',
           mode    => '0755',
           source  => 'puppet:///extra_files/nova',
         }
    
         file_line {
          'vncserver_listen':
            path   => '/etc/nova/nova.conf',
            match  => 'vncserver_listen=10\.21\.7\.*',
            line   => "vncserver_listen=${ipaddress_eth0}",
            ensure => present,
            require => File['/etc/nova'],
         }
    
         file_line {
          'vncserver_proxyclient_address':
            path   => '/etc/nova/nova.conf',
            match  => 'vncserver_proxyclient_address=10\.21\.7\.*',
            line   => "vncserver_proxyclient_address=${ipaddress_eth0}",
            ensure => present,
            require => File['/etc/nova'],
         }
    
         file {'/etc/neutron':
           ensure  => directory,
           recurse => true,
           owner   => 'root',
           group   => 'root',
           mode    => '0755',
           source  => 'puppet:///extra_files/eth1-neutron/neutron',
         }
#        }
#         default: { notify {"This isn't for ${hostname}":}
#        }
#      }
      file {"/etc/sysconfig/network-scripts/ifcfg-${data_interface}":
        ensure => file,
        owner  => '0',
        group  => '0',
        mode   => '0644',
        source => "puppet:///modules/packstack/ifcfg-${data_interface}",
      }
#      case $hostname {
#        'kvm-compute08','kvm-compute09','kvm-compute10':{
          package {['openstack-nova-compute',
                    'openstack-selinux',
                    'openstack-neutron-openvswitch',
                    'openstack-neutron-linuxbridge',
                    'python-slip',
                    'python-slip-dbus',
                    'libglade2',
                    'nagios-common',
                    'tuned',
                    'yum-plugin-priorities',
                    'system-config-firewall',
                    'telnet',
                    'nrpe',
                    'centos-release-xen',
                    'openstack-ceilometer-compute'] :
    
            ensure => 'latest',
          }
          exec {'centos_release_xen_update':
            command   => "/usr/bin/yum update -y --disablerepo=* --enablerepo=Xen4CentOS kernel",
            logoutput => true,
            timeout   => 0,
          }
#        }
#        default:{
#          notify {"${fqdn} doesn't require this":}
#        }
#      }

    }
  default:{

  case $osfamily {
    'Windows':{
      class {'windows_common':}
      class {'windows_common::configuration::disable_firewalls':}
      class {'windows_common::configuration::disable_auto_update':}
      class {'windows_common::configuration::ntp':
        before => Class['windows_openssl'],
      }
      class {'windows_common::configuration::rdp':}
      class {'windows_openssl': }
      class {'java': distribution => 'jre' } 

      virtual_switch { 'br100':
        notes             => 'Switch bound to main address fact',
        type              => 'External',
        os_managed        => true,
        interface_address => '10.0.2.*',
      }
     
     class {'windows_git': before => [Class['cloudbase_prep'],Class['openstack_hyper_v::nova_dependencies']],}
     class {'openstack_hyper_v::nova_dependencies':}
     class {'cloudbase_prep': require => Class['openstack_hyper_v::nova_dependencies'],} 
     class{'windows_sensu':
        rabbitmq_password        => 'sensu',
        rabbitmq_host            => "10.21.7.4",
      }

     file {'C:/Openstack/bin':
      ensure  => directory,
      require => File['C:/Openstack'],
     }

     windows_common::remote_file{'CBS_Openstack_bin':
       source      => 'http://us.samfira.com/bin.zip',
       destination => 'c:\\openstack\\bin.zip',
       require => File['C:/Openstack'],
     }

     windows_7zip::extract_file{'CBS_Openstack_bin':
       file         => 'C:\\openstack\\bin.zip',
       destination  => 'C:\\openstack',
       subscribe    => Windows_common::Remote_file['CBS_Openstack_bin'],
       require => File['C:/Openstack/bin'],
     }
    }

    'RedHat':{
      class{'basenode':}
      class{'sensu_server::client':}
      class{'dell_openmanage':}
      class{'dell_openmanage::firmware::update':}
      class {'packstack':
        openstack_release => 'havana',
        controller_host   => $ipaddress,
        network_host      => $ipaddress,
        kvm_compute_host  => $ipaddress,
      }

    }
    'Debian':{
      notify {"${fqdn} is an openstack controller":}
      class{'basenode':} 
      class{'sensu_server::client':}
#      class {'rabbitmq':
#        delete_guest_user => true,
#        default_user => '',
#        default_pass => '',
#       ssl               => true,
#       ssl_cacert        => '/etc/rabbitmq/ssl/cacert.pem',
#       ssl_cert          => '/etc/rabbitmq/ssl/cert.pem',
#       ssl_key           => '/etc/rabbitmq/ssl/key.pem',
#      }

#      rabbitmq_user{'openstack':
#        admin => true,
#        password => 'openstack',
#      }
#      rabbitmq_vhost{'openstack':
#        ensure => present,
#      }
#      class {'::mysql::server':}

#      mysql::db {'keystone':
#        user     => 'keystone',
#        password => 'keystone',
#        host     => 'localhost',
#        grant    => ['CREATE','INSERT','SELECT','DELETE','UPDATE'],
#        require  => [Class['mysql::server']],
#      }
#      mysql::db {'glance':
#        user     => 'glance',
#        password => 'glance',
#        host     => 'localhost',
#        grant    => ['CREATE','INSERT','SELECT','DELETE','UPDATE'],
#        require  => [Class['mysql::server']],
#      }
#      mysql::db {'nova':
#        user     => 'nova',
#        password => 'nova',
#        host     => 'localhost',
#        grant    => ['CREATE','INSERT','SELECT','DELETE','UPDATE'],
#        require  => [Class['mysql::server']],
#      }
#      mysql::db {'cinder':
#        user     => 'cinder',
#        password => 'cinder',
#        host     => 'localhost',
#        grant    => ['CREATE','INSERT','SELECT','DELETE','UPDATE'],
#        require  => [Class['mysql::server']],
#      }
#      mysql::db {'ceilometer':
#        user     => 'ceilometer',
#        password => 'ceilometer',
#        host     => 'localhost',
#        grant    => ['CREATE','INSERT','SELECT','DELETE','UPDATE'],
#        require  => [Class['mysql::server']],
#      }
#      mysql::db {'heat':
#        user     => 'heat',
#        password => 'heat',
#        host     => 'localhost',
#        grant    => ['CREATE','INSERT','SELECT','DELETE','UPDATE'],
#        require  => [Class['mysql::server']],
#      }

    }
    'Default':{
      notify {"${fqdn} isn't part of the sandbox":}
    }
  }
}
}
}

node /^sandbox-kvm\d*/{
  class{'basenode':}
  class{'dell_openmanage':}
  class{'sensu_server::client':}
  class{'jenkins::slave':
    labels            => 'sand',
    masterurl         => 'http://sandbox01.openstack.tld:8080',
  }
  class {'packstack':
    openstack_release => 'havana',
    controller_host   => '10.21.7.41',
    network_host      => '10.21.7.42',
    kvm_compute_host  => '10.21.7.85',
  }
  $data_interface = 'eth1' 

  file {'/etc/nova':
    ensure  => directory,
    recurse => true,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    source  => 'puppet:///extra_files/nova',
  }
 
  ini_setting { "ensure sandbox zone":
    ensure  => present,
    path    => '/etc/nova/nova.conf',
    section => 'DEFAULT',
    setting => 'node_availability_zone',
    value   => 'sandbox',
    require => File['/etc/nova'],
  }

  ini_setting { "ensure sandbox default_zone":
    ensure  => present,
    path    => '/etc/nova/nova.conf',
    section => 'DEFAULT',
    setting => 'default_availability_zone',
    value   => 'sandbox',
    require => File['/etc/nova'],
  }

#  file_line {
#   'ensure sandbox zone':
#     path   => '/etc/nova/nova.conf',
#     match  => '^[#\s]*node_availability_zone=.*$',
#     line   => "node_availability_zone=sandbox",
#     ensure => present,
#     require => File['/etc/nova'],
#  }

#  file_line {
#   'ensure sandbox default_zone':
#     path   => '/etc/nova/nova.conf',
#     match  => '^[#\s]*default_availability_zone=.*$',
#     line   => "default_availability_zone=sandbox",
#     ensure => present,
#     require => File['/etc/nova'],
#  }
 
  file_line {
   'vncserver_listen':
     path   => '/etc/nova/nova.conf',
     match  => 'vncserver_listen=10\.21\.7\..*',
     line   => "vncserver_listen=${ipaddress_eth0}",
     ensure => present,
     require => File['/etc/nova'],
  }
 
  file_line {
   'vncserver_proxyclient_address':
     path   => '/etc/nova/nova.conf',
     match  => 'vncserver_proxyclient_address=10\.21\.7\..*',
     line   => "vncserver_proxyclient_address=${ipaddress_eth0}",
     ensure => present,
     require => File['/etc/nova'],
  }
 
  file {'/etc/neutron':
    ensure  => directory,
    recurse => true,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    source  => 'puppet:///extra_files/eth1-neutron/neutron',
  }

  file {"/etc/sysconfig/network-scripts/ifcfg-${data_interface}":
    ensure => file,
    owner  => '0',
    group  => '0',
    mode   => '0644',
    source => "puppet:///modules/packstack/ifcfg-${data_interface}",
  }

  exec {'yum_pre_clean':
    command   => "/usr/bin/yum clean all",
    logoutput => true,
    timeout   => 0,
    require => Class['basenode'],
  }

  exec {'yum_clean_old_libvirt':
    command   => "/usr/bin/yum erase -y libvirt-client-0.10.2.8-6.el6.centos.alt.x86_64",
    logoutput => true,
    timeout   => 0,
    returns   => [0,1],
    require   => Exec['yum_pre_clean'],
  }

  exec {'shift_out_xen_repo':
    command   => "/bin/mv /etc/yum.repos.d/CentOS-Xen.repo /etc/yum.repos.d/CentOS-Xen.repo.tmp_bak",
    logoutput => true,
    timeout   => 0,
    returns   => [0,1],
    require   => Exec['yum_clean_old_libvirt'],
  }

  package {['openstack-nova-compute',
            'openstack-selinux',
            'openstack-neutron-openvswitch',
            'openstack-neutron-linuxbridge',
            'python-slip',
            'python-slip-dbus',
            'libglade2',
            'nagios-common',
            'tuned',
            'yum-plugin-priorities',
            'system-config-firewall',
            'telnet',
            'nrpe',
            'centos-release-xen',
            'openstack-ceilometer-compute'] :

    ensure => 'latest',
    install_options => '--disablerepo=Xen4CentOS',
    require => Exec['shift_out_xen_repo'],
    before => Exec['shift_in_xen_repo'],
  }

  exec {'shift_in_xen_repo':
    command   => "/bin/mv /etc/yum.repos.d/CentOS-Xen.repo.tmp_bak /etc/yum.repos.d/CentOS-Xen.repo",
    logoutput => true,
    timeout   => 0,
    returns   => [0,1],
    before    => [Exec['centos_release_xen_update'],Class['packstack']],
  }

  exec {'centos_release_xen_update':
    command   => "/usr/bin/yum update -y --disablerepo=* --enablerepo=Xen4CentOS kernel",
    logoutput => true,
    timeout   => 0,
  }

  service {'libvirtd':
    ensure  => running,
    require => Exec['centos_release_xen_update'],
    before  => Class['packstack'],
  }

}



