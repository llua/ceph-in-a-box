Vagrant.configure(2) do |config|

  config.vm.define "ceph-aio" do |aio|
    aio.vm.provider :virtualbox do |vb|
      vb.memory = 2048
    end
    aio.vm.box = "nexcess/stark-cent7.2"
    aio.vm.hostname = "ceph-aio-centos7.ceph-n-a-box.io"
    aio.vm.network :private_network, ip: "192.168.42.111"
    aio.vm.network :private_network, ip: "192.168.43.222"
  end

  config.vm.define "ceph-mon" do |mon|
    mon.vm.provider :virtualbox do |vb|
      vb.memory = 1024
    end
    mon.vm.box = "nexcess/stark-cent7.2"
    mon.vm.hostname = "ceph-mon.ceph-n-a-box.io"
    mon.vm.network :private_network, ip: "192.168.42.11"
  end

  (1..3).each do |i|
    config.vm.define "ceph-osd#{i}" do |osd|
      osd.vm.provider :virtualbox do |vb|
        vb.memory = 1024
      end
      osd.vm.box = "nexcess/stark-cent7.2"
      osd.vm.hostname = "ceph-osd#{i}.ceph-n-a-box.io"
      osd.vm.network :private_network, ip: "192.168.42.2#{i}"
      osd.vm.network :private_network, ip: "192.168.43.2#{i}"
      osd.vm.provider :virtualbox do |vb|
        (0..1).each do |d|
          vb.customize ['createhd',
            '--filename', ".ceph/disk-#{i}-#{d}",
            '--size', '11000']
          vb.customize ['storageattach', :id,
            '--storagectl', 'SATA Controller',
            '--port', 3 + d,
            '--device', 0,
            '--type', 'hdd',
            '--medium', ".ceph/disk-#{i}-#{d}.vdi"]
        end
      end
    end
  end

  config.vm.define "ceph-rgw" do |rgw|
    rgw.vm.provider :virtualbox do |vb|
      vb.memory = 1024
    end
    rgw.vm.box = "nexcess/stark-cent7.2"
    rgw.vm.hostname = "ceph-rgw.ceph-n-a-box.io"
    rgw.vm.network :private_network, ip: "192.168.42.31"
  end

  config.vm.define "ceph-mds" do |mds|
    mds.vm.provider :virtualbox do |vb|
      vb.memory = 1024
    end
    mds.vm.box = "nexcess/stark-cent7.2"
    mds.vm.hostname = "ceph-mds.ceph-n-a-box.io"
    mds.vm.network :private_network, ip: "192.168.42.41"
  end

  config.vm.provision "shell", path: 'scripts/vagrant_puppet.sh'
end
