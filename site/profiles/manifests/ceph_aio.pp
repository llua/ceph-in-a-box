class profiles::ceph_aio {
  include ::profiles::ceph_mon
  include ::profiles::ceph_osd
  include ::profiles::ceph_rgw
  include ::profiles::ceph_mds

  Service["ceph-mon-${facts['hostname']}"] ->
  Exec['ceph-osd-activate-/dev/vdb'] ->
  Exec['ceph-osd-activate-/dev/vdc']
  #Service["ceph-mds-${facts['hostname']}"]
}
