class profiles::ceph_rgw {
  include ::profiles::base
  include ::profiles::ceph_common

  ceph::rgw { 'radosgw.gateway':
    user => hiera('ceph::params::user_radosgw'),
  } ->

  ceph::rgw::apache_fastcgi { 'client.radosgw.gateway':
    admin_email =>  hiera('ceph::rgw::apache_fastcgi::admin_email'),
    docroot     =>  hiera('ceph::rgw::apache_fastcgi::docroot'),
    fcgi_file   =>  hiera('ceph::rgw::apache_fastcgi::fcgi_file'),
  }

  if (!defined(Service['ceph-radosgw'])) {
    service {'ceph-radosgw':
      enable  => true,
      require => Package['ceph'],
    }
    Ceph::Rgw::Apache_fastcgi['client.radosgw.gateway'] -> Service['ceph-radosgw']
  }
}
