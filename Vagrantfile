# -*- mode: ruby -*-
# vi: set ft=ruby :
#
# For debian wheezy dev
# $ OS=debian7 vagrant up
# or (debian7 is default os)
# $ vagrant up
#
# For centos 6 dev
# $ OS=centos6 vagrant up

default = ENV['OS'] || 'debian7'

boxes = {
  'debian7' => {
    'name'  => 'debian-wheezy-amd64',
    'url'   => 'http://sebian.yasaw.net/pub/debian-wheezy-x64.box'
  },
  'centos6' => {
    'name'  => 'centos6.gitlab',
    'url'   => 'http://sroegner-vagrant.s3.amazonaws.com/Centos6_puppet3_virtualbox4.2.box'
  }
}

Vagrant::Config.run do |config|
  config.vm.define :gitlab do |hq|
    hq.vm.box = boxes[default]['name']
    config.vm.box_url = boxes[default]['url']

    hq.vm.host_name = "gitlab.localdomain.local"
    hq.vm.customize [ "modifyvm", :id , "--name", "gitlab_#{boxes[default]['name']}" , "--memory", "2048", "--cpus", "1"]

    hq.vm.network :hostonly, "192.168.111.10"

    hq.vm.share_folder "puppet_modules", "/srv/puppet_modules/gitlab", "."

    hq.vm.provision :puppet, :pp_path => "/srv/vagrant-puppet" do |puppet|
      #puppet.options = [ "--debug", "--modulepath", "/srv/puppet_modules", "--certname gitlab_server"]
      puppet.options = [ "--modulepath", "/srv/puppet_modules", "--certname gitlab_server"]
      puppet.manifests_path = "examples"
      puppet.manifest_file = "gitlab.pp"
    end
  end
end
