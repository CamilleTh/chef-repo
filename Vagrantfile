Vagrant::Config.run do |config|

  config.vm.network :bridged, :bridge => "eth0"
  config.vbguest.auto_update = true

  # do NOT download the iso file from a webserver
  config.vbguest.no_remote = true


  config.vm.box = "opscode-ubuntu-12.04box"
  config.vm.box_url = "http://files.vagrantup.com/precise64.box"
  config.vm.forward_port 80, 4567
  config.vm.forward_port 8080, 5678


  config.vm.provision :chef_client do |chef|
   chef.chef_server_url = "https://192.168.4.140"
   chef.validation_client_name = "chef-validator"
   chef.validation_key_path = "./.chef/chef-validator.pem"
   chef.node_name = "DeployVM"
  end
end
