class profiles::ceph_osd {
  include ::profiles::base
  include ::profiles::ceph_common

  if (!empty($facts['ceph_osd_auto_discovery'])) {
    $osds = $facts['ceph_osd_auto_discovery']
  }
  else {
    $osds = $ceph::profile::params::osds
  }

  #Ceph_Config<| |> ->

  class { '::ceph::osds':
    args => $osds,
  }
}
