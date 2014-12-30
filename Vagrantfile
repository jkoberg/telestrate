
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.box = "ubuntu/trusty64"
  config.vm.network "forwarded_port", guest: 8005, host: 8005
  config.vm.network "forwarded_port", guest: 8123, host: 8123

  config.vm.provision "shell", path: "provision.sh"
  
  config.vm.provider "virtualbox" do |v|
    v.customize ["setextradata", :id, "VBoxInternal2/SharedFoldersEnableSymlinksCreate/v-root", "1"]
    v.memory = 1024
    v.cpus = 2
  end

end
