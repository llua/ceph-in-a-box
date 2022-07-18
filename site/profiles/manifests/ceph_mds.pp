class profiles::ceph_mds {
  include ::profiles::base
  include ::profiles::ceph_common
  include ::ceph::mds

  #class {'::ceph::mds':} ->
  #file {"/var/lib/ceph/mds/ceph-${::hostname}":
  #  ensure => 'directory',
  #  owner  => 'root',
  #  group  => 'root',
  #  mode   => '0700',
  #} ->
  #file {"/var/lib/ceph/mds/ceph-${::hostname}/done":
  #  ensure => 'file',
  #} ->
  #file {"/var/lib/ceph/mds/ceph-${::hostname}/sysvinit":
  #  ensure => 'file',
  #} ->
  #service { "ceph-mds-${::hostname}":
  #  ensure => running,
  #  start  => "service ceph start mds.${::hostname}",
  #  stop   => "service ceph stop mds.${::hostname}",
  #  status => "service ceph status mds.${::hostname}",
  #}

  ## the ordering below is to ensure the mds keyring is created before
  ## starting the mds service
  #Ceph_Config <| |> ->
  #Ceph::Key["mds.${::hostname}"] ->
  #Service["ceph-mds-${::hostname}"]
}
