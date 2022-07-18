#!/usr/bin/env ruby
Vagrant.configure(2) do |config|
  config.vm.provider :libvirt do |libvirt|
    libvirt.memory = 1024
    libvirt.uri    = 'qemu:///system'
  end
  config.vm.box = 'centos/7'

  config.vm.define "ceph-aio" do |aio|
    aio.vm.provider :libvirt do |libvirt|
      libvirt.memory = 2048
      2.times do
        libvirt.storage :file, size: '5G'
      end
    end
    aio.vm.hostname = "ceph-aio.ceph-n-a-box.io"
    aio.vm.network :private_network, ip: "192.168.122.111"
  end

  config.vm.define "ceph-mon" do |mon|
    mon.vm.hostname = "ceph-mon.ceph-n-a-box.io"
    mon.vm.network :private_network, ip: "192.168.122.11"
  end

  (1..3).each do |i|
    config.vm.define "ceph-osd#{i}" do |osd|
      osd.vm.hostname = "ceph-osd#{i}.ceph-n-a-box.io"
      osd.vm.network :private_network, ip: "192.168.122.2#{i}"
      osd.vm.provider :libvirt do |libvirt|
        2.times do
          libvirt.storage :file, size: '2G'
        end
      end
    end
  end

  config.vm.define "ceph-rgw" do |rgw|
    rgw.vm.hostname = "ceph-rgw.ceph-n-a-box.io"
    rgw.vm.network :private_network, ip: "192.168.122.31"
  end

  config.vm.define "ceph-mds" do |mds|
    mds.vm.hostname = "ceph-mds.ceph-n-a-box.io"
    mds.vm.network :private_network, ip: "192.168.122.41"
  end

  config.vm.provision "shell", path: 'scripts/vagrant_puppet.sh'
end
