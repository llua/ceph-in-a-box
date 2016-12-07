class profiles::ceph_mon {
  include ::profiles::base
  include ::profiles::ceph_common

  ceph::mon { $facts['hostname']:
    authentication_type => $ceph::profile::params::authentication_type,
    key                 => $ceph::profile::params::mon_key,
    keyring             => $ceph::profile::params::mon_keyring,
  }
}
