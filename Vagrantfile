# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant::Config.run do |config|
  config.vm.define :gitlab do |hq|
    hq.vm.box = "ubuntu1204-amd64"
    hq.vm.host_name = "gitlab"
    hq.vm.network :hostonly, "192.168.1.10"
    # Rails port
    hq.vm.forward_port 3000, 13000
    # Http (nginx)
    hq.vm.forward_port 80, 8080
    # Ssh (gitolite)
    hq.vm.forward_port 22, 2222
    hq.vm.share_folder "puppet_modules", "/srv/puppet_modules/gitlab", "."
    hq.vm.provision :puppet, :pp_path => "/srv/vagrant-puppet", :options => ["--modulepath", "/srv/puppet_modules", "--certname gitlab_server"] do |puppet|
      puppet.manifests_path = "examples"
      puppet.manifest_file = "gitlab.pp"
    end
  end
end
