# Vagrantfile for Stage 1 - Ansible instrumentation
Vagrant.configure("2") do |config|
  config.vm.box = "geerlingguy/ubuntu2004"
  config.vm.hostname = "okoth-vm"
  config.vm.network "private_network", ip: "192.168.56.10"
  # Forward ports as a fallback so you can also access via localhost
  config.vm.network "forwarded_port", guest: 3002, host: 3002, auto_correct: true
  config.vm.network "forwarded_port", guest: 5001, host: 5001, auto_correct: true

  config.vm.provider "virtualbox" do |vb|
    vb.memory = 2048
    vb.cpus = 2
  end

  # Use ansible_local to avoid SSH key/cert configuration
  config.vm.provision "ansible_local" do |ansible|
    ansible.playbook = "playbook.yml"
    ansible.extra_vars = {
      ansible_python_interpreter: "/usr/bin/python3"
    }
  end
end
