NUM_MASTER_NODE = 1
NUM_WORKER_NODE = 3

IP_NW = "192.168.50."
MASTER_IP_START = 1
NODE_IP_START = 2

Vagrant.configure("2") do |config|

  config.vm.provision "shell", path: "bootstrap.sh"

  #config.vm.box = "ubuntu/bionic64"
  config.vm.box = "hashicorp/bionic64"
  config.vm.box_check_update = false

  (1..NUM_MASTER_NODE).each do |i|
    config.vm.define "kubemaster" do |node|
      # Name shown in the GUI
      node.vm.provider "virtualbox" do |vb|
          vb.name = "kubemaster"
          vb.memory = 2048
          vb.cpus = 2
      end
      node.vm.hostname = "kubemaster"
      node.vm.network :private_network, ip: IP_NW + "#{MASTER_IP_START + i}"
      node.vm.network "forwarded_port", guest: 22, host: "#{2710 + i}"
      node.vm.network "forwarded_port", guest: 8080, host: "8080"
      node.vm.network "forwarded_port", guest: 9000, host: "9090"

      node.vm.provision "shell", path: "bootstrap_kmaster.sh"
    end
  end

  (1..NUM_WORKER_NODE).each do |i|
    config.vm.define "kubenode0#{i}" do |node|
        node.vm.provider "virtualbox" do |vb|
            vb.name = "kubenode0#{i}"
            vb.memory = 2048
            vb.cpus = 2
        end
        node.vm.hostname = "kubenode0#{i}"
        node.vm.network :private_network, ip: IP_NW + "#{NODE_IP_START + i}"
        node.vm.network "forwarded_port", guest: 22, host: "#{2720 + i}"           

        node.vm.provision "shell", path: "bootstrap_kworker.sh"
    end
  end

end
