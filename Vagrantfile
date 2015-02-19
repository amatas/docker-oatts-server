# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|

  config.vm.box = "amatas/centos-7"

  config.vm.network "forwarded_port", guest: 8081, host: 8888
  config.vm.provider "virtualbox" do |v|
    v.gui = true
  end
  config.vm.synced_folder ".", "/data"

# Workaround to fix mounting a volume from the shared directory
$script = <<SCRIPT
systemctl restart docker
SCRIPT

  config.vm.provision "shell", 
    inline: $script,
    run: "always"


  config.vm.provision "docker", run: "always" do |d|
    d.run "mysql",
      args: "--name db -e MYSQL_ROOT_PASSWORD=root -e MYSQL_DATABASE=oatts -e MYSQL_USER=oatts -e MYSQL_PASSWORD=oattspw",
      daemonize: true
  end

  config.vm.provision "docker" do |d|
    d.build_image "/data",
      args: "-t 'trace/oatts-server-local'"

    d.run "mysql-provision",
      image: "trace/oatts-server-local",
      args: "-e DBUSER=oatts -e DBPASSWORD=oattspw -e DBDB=oatts -e LOADDB=yes --link db:database"
  end

  config.vm.provision "docker", run: "always" do |d|
    d.run "oatts",
      image: "trace/oatts-server-local",
      args: "-p 8081:80 -e SERVER_NAME=localhost -e DBUSER=oatts -e DBPASSWORD=oattspw -e DBDB=oatts -e BASEIP=127.0.0.1:8888 -e BASEDIR=''  --link db:database",
      daemonize: true
  end

end
