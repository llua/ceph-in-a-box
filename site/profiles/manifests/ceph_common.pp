class profiles::ceph_common {
  Ceph::Key {
    user  => 'ceph',
    group => 'ceph',
  }
  require ::ceph::profile::client
  create_resources(
    'ceph_config',
    lookup('ceph::conf::settings', Hash, 'deep')
  )
}
