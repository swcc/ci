# -*- mode: ruby -*-
# vi: set ft=ruby :

# You can ask for more memory and cores when creating your Vagrant machine:
# GITLAB_VAGRANT_MEMORY=2048 GITLAB_VAGRANT_CORES=4 vagrant up
VAGRANTFILE_API_VERSION = "2"
GUEST_IP="10.0.0.10"
GUEST_HOSTNAME="ci.swcc.dev"
MEMORY = ENV['GITLAB_VAGRANT_MEMORY'] || '1536'
CORES = ENV['GITLAB_VAGRANT_CORES'] || '2'

Vagrant.require_plugin "vagrant-berkshelf"
Vagrant.require_plugin "vagrant-omnibus"
Vagrant.require_plugin "vagrant-bindfs"

Vagrant.configure("2") do |config|
  config.vm.hostname = GUEST_HOSTNAME

  config.vm.box = "squeeze64" 
  config.vm.box_url = "https://dl.dropboxusercontent.com/u/13054557/vagrant_boxes/debian-squeeze.box"

  # Assign this VM to a host-only network IP, allowing you to access it
  # via the IP. Host-only networks can talk to the host machine as well as
  # any other machines on the same network, but cannot be accessed (through this
  # network interface) by any external networks.
  config.vm.network :private_network, ip: GUEST_IP
  config.vm.network :forwarded_port, guest: 80, host: 8080

  # We don't need to mount /vagrant directory since we use git user
  # Using bindfs to remount synced folder in order to have the correct ownership
  config.vm.synced_folder ".", "/vagrant", :disabled => true
  config.vm.synced_folder "./home_git", "/git-nfs", :nfs => true
  config.bindfs.bind_folder "/git-nfs", "/home/git", :owner => "1111", :group => "1111", :'create-as-user' => true, :perms => "u=rwx:g=rwx:o=rwx", :'create-with-perms' => "u=rwx:g=rwx:o=rwx", :'chown-ignore' => true, :'chgrp-ignore' => true, :'chmod-ignore' => true

  config.vm.provider :virtualbox do |v|
    # Use VBoxManage to customize the VM. For example to change memory:
    v.customize ["modifyvm", :id, "--memory", MEMORY.to_i]
    v.customize ["modifyvm", :id, "--cpus", CORES.to_i]

    if CORES.to_i > 1
      v.customize ["modifyvm", :id, "--ioapic", "on"]
    end
  end

  config.vm.provider :vmware_fusion do |v, override|
    override.vm.box_url = "http://files.vagrantup.com/precise64_vmware.box"
    v.vmx["memsize"] = MEMORY
    v.vmx["numvcpus"] = CORES
  end

  config.vm.provider :parallels do |v, override|
    v.customize ["set", :id, "--memsize", MEMORY, "--cpus", CORES]
  end
  
  # Install the version of Chef by the Vagrant Omnibus
  # version is :latest or "11.4.0"
  # Note:
  # Using version "11.4.4" because that is the latest version
  # AWS OpsWorks supports
  config.omnibus.chef_version = "11.4.4"

  # Enabling the Berkshelf plugin. To enable this globally, add this configuration
  # option to your ~/.vagrant.d/Vagrantfile file
  config.berkshelf.enabled = true

  config.vm.provision :chef_solo do |chef|
    chef.json = {
      "gitlab" => {
        "env" => "production",
        "user_uid" => 1111,
        "user_gid" => 1111
      },
      "phantomjs" => {
        "version" => "1.8.1"
      }
    }
    chef.run_list = [
      "apt",
      "postfix",
      "gitlab::default"
    ]
    # In case chef-solo run is failing silently
    # uncomment the line below to enable debug log level.
    # chef.arguments = '-l debug'
  end
end

# The script will login "git" user right away when doing "vagrant ssh"
Vagrant.configure("2") do |config|
  config.vm.provision :shell, :path => "./git_login.sh"
end
