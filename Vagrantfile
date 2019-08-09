# -*- mode: ruby -*-
# vi: set ft=ruby :

VM_NAME="your-vm-name"

# set the timezone and a nicer bash prompt
$script = <<-SCRIPT
sudo rm /etc/localtime
sudo ln -s /usr/share/zoneinfo/America/Montreal /etc/localtime
echo "export PS1='\\[\\e[0;36m\\]\\u\\[\\e[0m\\]@\\[\\e[0;33m\\]\\h\\[\\e[0m\\]:\\[\\e[0;35m\\]\\w\\[\\e[0m\\] \\$ '" >> .bashrc
touch .bash_profile ; chown vagrant:vagrant .bash_profile
echo "source ~/.bashrc" >> .bash_profile
SCRIPT

Vagrant.configure("2") do |config|

  config.vm.box = "centos/7"
  config.vm.box_check_update = false
  
  config.ssh.insert_key = true

  config.vm.provision "shell", inline: $script

  config.vm.define VM_NAME do |server|
    
    server.vm.provider "virtualbox" do |vb|
      vb.name = VM_NAME
      vb.customize ["modifyvm", :id, "--cpus", "4"]
      vb.memory = 4096
      vb.default_nic_type = "82543GC"
    end  

    server.vm.hostname = VM_NAME
    server.vm.network "private_network", ip: "10.0.0.50", nic_type: "virtio"

  end

  # author
  config.vm.network "forwarded_port", guest: 4502, host: 4502
  
  # publish
  config.vm.network "forwarded_port", guest: 4503, host: 4503
  
end