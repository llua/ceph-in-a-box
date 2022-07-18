class profiles::ceph_rgw {
  include ::profiles::base
  include ::profiles::ceph_common

  ceph::rgw { "radosgw.${facts['hostname']}":
    user => lookup('ceph::params::user_radosgw'),
  }
}
