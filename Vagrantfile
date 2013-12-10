# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"
GUEST_IP="10.0.0.10"
GUEST_HOSTNAME="ci.swcc.dev"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.box = "squeeze64"

  config.vm.box_url = "https://dl.dropboxusercontent.com/u/13054557/vagrant_boxes/debian-squeeze.box"
  # config.vm.box_url = "https://dl.dropboxusercontent.com/s/xymcvez85i29lym/vagrant-debian-wheezy64.box"

  config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, "--memory", "1024"]
    vb.customize ["modifyvm", :id, "--cpus", "2"]
  end
  
  config.vm.hostname = GUEST_HOSTNAME
  config.vm.boot_timeout = 600


  # Network
  config.vm.network "forwarded_port", guest: 80, host: 8080
  config.vm.network "forwarded_port", guest: 81, host: 8081
  config.vm.network :private_network, ip: GUEST_IP

  # Provisionning
  config.vm.provision "shell", path: "install.sh"

end
