# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant::Config.run do |config|

  config.vm.define :debian do |debian|
    debian.vm.box = "wheezy.gitlab"
    debian.vm.box_url ='http://sebian.yasaw.net/pub/debian-wheezy-x64.box' 

    debian.vm.host_name = "gitlab.gitlab.local"
    debian.vm.network :hostonly, "192.168.111.10"

    debian.vm.share_folder "puppet_modules", "/srv/puppet_modules/gitlab", "."

    debian.vm.provision :puppet, :pp_path => "/srv/vagrant-puppet" do |puppet|
      #puppet.options = [ "--debug", "--modulepath", "/srv/puppet_modules", "--certname gitlab_server"]
      puppet.options = [ "--modulepath", "/srv/puppet_modules", "--certname gitlab_server"]
      puppet.manifests_path = "examples"
      puppet.manifest_file = "gitlab.pp"
    end
  end

  config.vm.define :centos do |centos|
    centos.vm.box = "centos6.gitlab"
    centos.vm.box_url ='http://sroegner-vagrant.s3.amazonaws.com/Centos6_puppet3_virtualbox4.2.box'

    centos.vm.host_name = "centos.gitlab.local"
    centos.vm.network :hostonly, "192.168.111.11"

    centos.vm.share_folder "puppet_modules", "/srv/puppet_modules/gitlab", "."
    centos.vm.provision :puppet, :pp_path => "/srv/vagrant-puppet" do |puppet|
      #puppet.options = [ "--debug", "--modulepath", "/srv/puppet_modules", "--certname gitlab_server"]
      puppet.options = [ "--modulepath", "/srv/puppet_modules", "--certname gitlab_server"]
      puppet.manifests_path = "examples"
      puppet.manifest_file = "gitlab.pp"
    end
  end
  
    # port forwarding is only needed if using port 80 via the host-only if isn't good enough
    # hq.vm.forward_port 3000, 13000
    # hq.vm.forward_port 80, 8080
    # hq.vm.forward_port 22, 2222

end
