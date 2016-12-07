class profiles::ceph_common {
  require ::ceph::profile::client

  $settings = hiera_hash('ceph::conf::settings')
  create_resources('ceph_config', $settings)

  # required for sysvinit, can be removed when jewel releases
  package {'redhat-lsb-core':
    ensure => 'present',
  }
  Package['redhat-lsb-core'] -> Service <| |>
}
