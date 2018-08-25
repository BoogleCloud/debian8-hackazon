# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  config.vm.box = "generic/debian8"
  config.vm.define "debian8-hackazon"
  config.vm.hostname = "debian8-hackazon"
  config.vm.synced_folder ".", "/vagrant", disabled: true
  
  
  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  # config.vm.box_check_update = false

  config.vm.network "public_network", bridge: "langrill.local"
  
  config.vm.provider "hyperv" do |h|
    h.vmname = config.vm.hostname
    h.linked_clone = true
    h.cpus = 2
    h.memory = 2048
  end
  
  config.vm.provision "resources", type: "file", source: "resources", destination: "/tmp/resources"
  config.vm.provision "bootstrap", type: "shell", path: "bootstrap.sh"
  config.vm.provision "debian8-hackazon", type: "shell", path: "debian8-hackazon.sh"
  
end
