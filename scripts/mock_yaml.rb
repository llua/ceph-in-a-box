#!/opt/puppetlabs/puppet/bin/ruby
require 'yaml'

settings_for_modules = {}

hostname = ARGV[0]
if hostname.include?('.')
  hostname = ARGV[0].split('.').first
end

if hostname.start_with?('ceph')
  settings_for_modules['ceph::profile::params::release']  = 'jewel'
  settings_for_modules['ceph::profile::params::fsid']     = '31c6c27c-4383-424e-ac30-8d7b08326903'
  settings_for_modules['ceph::profile::params::mon_key']  = 'AQCVZZ1Vwm+WJRAAlCJcyeMOf+bbM/q6hgo2vQ=='
  settings_for_modules['ceph::profile::params::authentication_type'] = 'cephx'
  settings_for_modules['ceph::profile::params::osd_journal_size'] = 100
  settings_for_modules['ceph::profile::params::osd_pool_default_pg_num'] = 256
  settings_for_modules['ceph::profile::params::osd_pool_default_pgp_num'] = 256
  settings_for_modules['ceph::profile::params::osd_pool_default_size'] = 3
  settings_for_modules['ceph::profile::params::osd_pool_default_min_size'] = 2
  settings_for_modules['ceph::profile::params::mon_host'] = '192.168.42.11'
  settings_for_modules['ceph::profile::params::mon_initial_members'] = 'ceph-mon'
  settings_for_modules['ceph::profile::params::public_network']  = '192.168.42.0/24'
  settings_for_modules['ceph::profile::params::cluster_network'] = '192.168.43.0/24'
  settings_for_modules['ceph::conf::settings'] = {
    'mon/mon_osd_full_ratio' => { value: 0.95 },
    'mon/mon_osd_nearfull_ratio' => { value: 0.85 },
    'mon/mon_osd_allow_primary_affinity' => { value: 'true' },
    'client/rbd_concurrent_management_ops' => { value: 20 },
    'client/rbd_default_format' => { value: 2 },
    #'client/rbd_default_features' => { value: 3 },
    'client/rbd_default_map_options' => { value: 'rw' },
    # osd tuning
    'osd/filestore_merge_threshold' => { value: 40 },
    'osd/filestore_split_multiple' => { value: 8 },
    'osd/osd_op_threads' => { value: 8 },
    'osd/filestore_op_threads' => { value: 8 },
    # recovery tuning
    'osd/osd_recovery_max_active' => { value: 5 },
    'osd/osd_max_backfills' => { value: 2 },
    'osd/osd_recovery_op_priority' => { value: 2 },
    'osd/osd_recovery_max_chunk' => { value: 1048576 },
    'osd/osd_recovery_threads' => { value: 1 },
    'osd/osd_objectstore' => { value: 'filestore' },
    'osd/osd_crush_update_on_start' => { value: 1 },
    # deep scrub
    'osd/osd_scrub_sleep' => { value: 0.1 },
    'osd/osd_disk_thread_ioprio_class' => { value: 'idle' },
    'osd/osd_disk_thread_ioprio_priority' => { value: 0 },
    'osd/osd_scrub_chunk_max' => { value: 5 },
    'osd/deep_scrub_stride' => { value: 1048576 },
  }
  settings_for_modules['ceph::profile::params::client_keys'] = {
    'client.admin' => {
      'secret'  => 'AQDLZp1Vg9VRGhAAQALeX1qaDZtt1HdH62Ub3A==',
      'mode'    => '0600',
      'cap_mon' => 'allow *',
      'cap_osd' => 'allow *',
      'cap_mds' => 'allow *',
    },
    'client.bootstrap-osd' => {
      'secret'       => 'AQAEBKhV3dvVHBAAZv1SEFqju6k2FCtRYRTWAA==',
      'keyring_path' => '/var/lib/ceph/bootstrap-osd/ceph.keyring',
      'cap_mon'      => 'allow profile bootstrap-osd',
    },
    'client.bootstrap-mds' => {
      'secret'       => 'AQD9PKhWNQPFGhAAEUcClqnQsQij5sOd6+jXiw==',
      'keyring_path' => '/var/lib/ceph/bootstrap-mds/ceph.keyring',
      'cap_mon'      => 'allow profile bootstrap-mds',
    },
  }
end

if hostname.start_with?('ceph-mon')
  settings_for_modules['ceph::profile::params::client_keys'].merge!({
    'mds.ceph-mds' => {
      'secret'  => 'AQCLPahWu5v9LhAA3kQlqwESs9FdU9uzVZon1g==',
      'cap_mds' => 'allow',
      'cap_mon' => 'allow profile mds',
      'cap_osd' => 'allow rwx',
    },
    'client.radosgw.gateway' => {
      'secret'  => 'AQA0TVRTsP/aHxAAFBvntu1dSEJHxtJeFFrRwg==',
      'cap_mon' => 'allow rwx',
      'cap_osd' => 'allow rwx',
    }
  })

  settings_for_modules['ceph::profile::params::client_keys'].each do |key|
    key[1]['inject']         = 'true'
    key[1]['inject_as_id']   = 'mon.'
    key[1]['inject_keyring'] = "/var/lib/ceph/mon/ceph-%{::hostname}/keyring"
  end
end

if hostname.start_with?('ceph-osd')
  settings_for_modules['ceph::profile::params::osds'] = {
    '/dev/sdb' => {},
    '/dev/sdc' => {},
  }
end

if hostname.start_with?('ceph-mds')
  settings_for_modules['ceph::mds::keyring']  = '/var/lib/ceph/mds/$cluster-%{::hostname}/keyring'
  settings_for_modules['ceph::mds::mds_data'] = '/var/lib/ceph/mds/$cluster-%{::hostname}'
  settings_for_modules['ceph::profile::params::client_keys'].merge!({
    'mds.%{::hostname}' => {
      'secret'       => 'AQCLPahWu5v9LhAA3kQlqwESs9FdU9uzVZon1g==',
      'keyring_path' => '/var/lib/ceph/mds/ceph-%{::hostname}/keyring',
    },
  })
end

if hostname.start_with?('ceph-rgw')
  settings_for_modules['ceph::repo::fastcgi'] = 'true'
  settings_for_modules['ceph::params::user_radosgw'] = 'root'
  settings_for_modules['ceph::rgw::apache_fastcgi::admin_email'] = 'sysops@ceph-n-a-box.io'
  settings_for_modules['ceph::rgw::apache_fastcgi::docroot'] =  '/var/www/html'
  settings_for_modules['ceph::rgw::apache_fastcgi::fcgi_file'] = '%{hiera("ceph::rgw::apache_fastcgi::docroot")}/s3gw.fcgi'
  settings_for_modules['ceph::params::rgw_socket_path'] = '%{hiera("ceph::rgw::apache_fastcgi::docroot")}/ceph.radosgw.gateway.fastcgi.sock'
  settings_for_modules['ceph::rgw::apache_fastcgi::custom_apache_ports'] = ['80','443']
  settings_for_modules['ceph::profile::params::client_keys'].merge!({
    'client.radosgw.gateway' => {
      'user'    => 'root',
      'secret'  => 'AQA0TVRTsP/aHxAAFBvntu1dSEJHxtJeFFrRwg==',
    }
  })
end

if hostname.start_with?('ceph-aio')
  if File.read('/proc/1/environ') =~ /container=docker/
    settings_for_modules['ceph::profile::params::mon_host'] = '%{networking.interfaces.eth0.bindings.0.address}'
    settings_for_modules['ceph::profile::params::public_network'] = '%{networking.interfaces.eth0.bindings.0.network}/24'
    settings_for_modules.delete('ceph::profile::params::cluster_network')
  else
    settings_for_modules['ceph::profile::params::mon_host'] = '192.168.42.111'
  end
  settings_for_modules['ceph::profile::params::mon_initial_members'] = '%{::hostname}'
  settings_for_modules['ceph::profile::params::osds'] = {
    '/srv/osd1' => {},
    '/srv/osd2' => {},
  }
  settings_for_modules['ceph::mds::keyring']  = '/var/lib/ceph/mds/$cluster-%{::hostname}/keyring'
  settings_for_modules['ceph::mds::mds_data'] = '/var/lib/ceph/mds/$cluster-%{::hostname}'
  settings_for_modules['ceph::repo::fastcgi'] = 'true'
  settings_for_modules['ceph::params::user_radosgw'] = 'root'
  settings_for_modules['ceph::rgw::apache_fastcgi::admin_email'] = 'sysops@ceph-n-a-box.io'
  settings_for_modules['ceph::rgw::apache_fastcgi::docroot'] =  '/var/www/html'
  settings_for_modules['ceph::rgw::apache_fastcgi::fcgi_file'] = '%{hiera("ceph::rgw::apache_fastcgi::docroot")}/s3gw.fcgi'
  settings_for_modules['ceph::params::rgw_socket_path'] = '%{hiera("ceph::rgw::apache_fastcgi::docroot")}/ceph.radosgw.gateway.fastcgi.sock'
  settings_for_modules['ceph::profile::params::osd_pool_default_size'] = 1
  settings_for_modules['ceph::profile::params::osd_pool_default_min_size'] = 1
  settings_for_modules['ceph::conf::settings'].merge!({
    'osd/osd_crush_chooseleaf_type' => { value: 0 },
  })
  settings_for_modules['ceph::profile::params::client_keys'] = {
    'client.admin' => {
      'secret'  => 'AQDLZp1Vg9VRGhAAQALeX1qaDZtt1HdH62Ub3A==',
      'mode'    => '0600',
      'cap_mon' => 'allow *',
      'cap_osd' => 'allow *',
      'cap_mds' => 'allow *',
    },
    'client.bootstrap-osd' => {
      'secret'       => 'AQAEBKhV3dvVHBAAZv1SEFqju6k2FCtRYRTWAA==',
      'keyring_path' => '/var/lib/ceph/bootstrap-osd/ceph.keyring',
      'cap_mon'      => 'allow profile bootstrap-osd',
    },
    'client.bootstrap-mds' => {
      'secret'       => 'AQD9PKhWNQPFGhAAEUcClqnQsQij5sOd6+jXiw==',
      'keyring_path' => '/var/lib/ceph/bootstrap-mds/ceph.keyring',
      'cap_mon'      => 'allow profile bootstrap-mds',
    },
    'mds.%{::hostname}' => {
      'secret'       => 'AQCLPahWu5v9LhAA3kQlqwESs9FdU9uzVZon1g==',
      'cap_mds'      => 'allow',
      'cap_mon'      => 'allow profile mds',
      'cap_osd'      => 'allow rwx',
      'keyring_path' => '/var/lib/ceph/mds/ceph-%{::hostname}/keyring',
    },
    'client.radosgw.gateway' => {
      'secret'  => 'AQA0TVRTsP/aHxAAFBvntu1dSEJHxtJeFFrRwg==',
      'user'    => 'root',
      'cap_mon' => 'allow rwx',
      'cap_osd' => 'allow rwx',
    }
  }

  settings_for_modules['ceph::profile::params::client_keys'].each do |key|
    key[1]['inject']         = 'true'
    key[1]['inject_as_id']   = 'mon.'
    key[1]['inject_keyring'] = "/var/lib/ceph/mon/ceph-%{::hostname}/keyring"
  end
end

puts settings_for_modules.to_yaml
