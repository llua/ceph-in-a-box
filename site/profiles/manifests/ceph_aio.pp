class profiles::ceph_aio {
  include ::profiles::ceph_monitor
  include ::profiles::ceph_osd
  include ::profiles::ceph_rgw
  include ::profiles::ceph_mds
  include ::profiles::ceph_rgw

  Service["ceph-mon-${::hostname}"] ->
  Exec['ceph-osd-activate-/srv/osd1'] ->
  Exec['ceph-osd-activate-/srv/osd2'] ->
  Service["ceph-mds-${::hostname}"]
}
