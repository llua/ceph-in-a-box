#!/opt/puppetlabs/puppet/bin/ruby

require 'yaml'

enc = Hash.new {|h,k| h[k] = Array.new}

case ARGV[0]
when /^ceph-mon/
  enc['classes'].push('roles::ceph_mon')
when /^ceph-osd/
  enc['classes'].push('roles::ceph_osd')
when /^ceph-rgw/
  enc['classes'].push('roles::ceph_rgw')
when /^ceph-mds/
  enc['classes'].push('roles::ceph_mds')
when /^ceph-aio/
  enc['classes'].push('roles::ceph_aio')
end

puts enc.to_yaml
