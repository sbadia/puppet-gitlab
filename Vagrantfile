# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant::Config.run do |config|
  config.vm.define :gitlab do |hq|
    hq.vm.box = "ubuntu1204-amd64"
    config.vm.box_url ='http://sebian.yasaw.net/pub/debian-wheezy-x64.box' 

    hq.vm.host_name = "gitlab.localdomain.local"
    hq.vm.network :hostonly, "192.168.111.10"

    # port forwarding is only needed if using port 80 via the host-only if isn't good enough
    # hq.vm.forward_port 3000, 13000
    # hq.vm.forward_port 80, 8080
    # hq.vm.forward_port 22, 2222

    hq.vm.share_folder "puppet_modules", "/srv/puppet_modules/gitlab", "."

    hq.vm.provision :puppet, :pp_path => "/srv/vagrant-puppet" do |puppet|
      #puppet.options = [ "--debug", "--modulepath", "/srv/puppet_modules", "--certname gitlab_server"]
      puppet.options = [ "--modulepath", "/srv/puppet_modules", "--certname gitlab_server"]
      puppet.manifests_path = "examples"
      puppet.manifest_file = "gitlab.pp"
    end

  end
end
