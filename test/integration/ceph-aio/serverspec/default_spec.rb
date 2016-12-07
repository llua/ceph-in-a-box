require 'serverspec'

set :backend, :exec

describe package('ceph') do
  it { should be_installed }
end

hostname = %x{hostname -s}.chomp

describe 'ceph release == hammer' do
  describe command('ceph -v') do
    its(:stdout) { should match /0\.94/ }
  end
end
# hammer still uses sysvinit scripts on rhel/centos and uses
# systemd-run to start the mon daemon, so the daemon is managed by
# systemd, but not really a service. so service() has (nothingtodo)
describe 'ceph monitor service is enabled' do
  describe file("/var/lib/ceph/mon/ceph-#{hostname}/done") do
    it { should exist }
  end
  describe file("/var/lib/ceph/mon/ceph-#{hostname}/sysvinit") do
    it { should exist }
  end
end

describe 'ceph monitor daemon is running' do
  describe process('ceph-mon') do
    its(:args) { should match /-i ceph-aio/ }
    it { should be_running }
  end
end

describe 'ceph osd daemons is running' do
  (0..1).each do |n|
    describe command("ceph daemon osd.#{n} status") do
      its(:stdout) { should match /state.*active/ }
    end
  end
end

describe 'ceph osd service is enabled' do
  (1..2).each do |n|
    describe file("/srv/osd#{n}/sysvinit") do
      it { should exist }
    end
  end
end

describe 'ceph mds daemon is running' do
  describe command("service ceph status mds") do
    its(:stdout) { should match /mds.#{hostname}: running/ }
  end
end

describe 'ceph osd service is enabled' do
  describe file("/var/lib/ceph/mds/ceph-#{hostname}/done") do
    it { should exist }
  end
  describe file("/var/lib/ceph/mds/ceph-#{hostname}/sysvinit") do
    it { should exist }
  end
end

describe 'ceph radosgw service is enabled' do
  describe file('/var/lib/ceph/radosgw/ceph-radosgw.gateway/sysvinit') do
    it { should exist }
  end
end

describe 'ceph radosgw service is running' do
  describe process('radosgw') do
    its(:args) { should match /-n client.radosgw.gateway\b/ }
  end
end

describe 'ceph sysvinit services enabled' do
  describe command('chkconfig --list 2>&1 | grep "^ceph "') do
      its(:stdout) { should match /3:on/ }
  end
  describe command('chkconfig --list 2>&1 | grep "^ceph-radosgw "') do
      its(:stdout) { should match /3:on/ }
  end
end
