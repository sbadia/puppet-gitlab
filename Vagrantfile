# -*- mode: ruby -*-
# vi: set ft=ruby :
#
# For debian wheezy dev
# $ GUEST_OS=debian7 vagrant up
# or (debian7 is default os)
# $ vagrant up
#
# For centos 6 dev
# $ GUEST_OS=centos6 vagrant up

default_type = 'debian7'
type = ENV['GUEST_OS'] || default_type

boxes = {
  'debian7' => {
    'name'  => 'debian-wheezy-amd64',
    'url'   => 'https://vagrant.irisa.fr/boxes/debian-wheezy-x64-puppet_3.0.1.box'
  },
  'ubuntu' => {
    'name'  => 'ubuntu-server-amd64',
    'url'   => 'http://sroegner-vagrant.s3.amazonaws.com/ubuntu_srv_12.10-amd64.box'
  },
  'centos6' => {
    'name'  => 'centos6.gitlab',
    'url'   => 'http://sroegner-vagrant.s3.amazonaws.com/gitlab-centos6-VirtualBox-4.2.6.box'
  }
}

box_data = boxes[type] || boxes[default_type]

Vagrant::Config.run do |config|
  config.vm.define :gitlab do |hq|
    hq.vm.box     = box_data['name']
    hq.vm.box_url = box_data['url']

    hq.vm.customize [ "modifyvm", :id , "--name", "gitlab_#{box_data['name']}" , "--memory", "2048", "--cpus", "1"]
    hq.vm.host_name = "gitlab.localdomain.local"
    hq.vm.network :hostonly, "192.168.111.10"
    #
    hq.vm.share_folder "sbadia_gitlab", "/srv/puppet_modules/gitlab", "."
    # https://github.com/puppetlabs/puppetlabs-mysql
    hq.vm.share_folder "puppetlabs_mysql", "/srv/puppet_modules/mysql", "modules/puppetlabs-mysql/"
    # https://github.com/puppetlabs/puppetlabs-stdlib
    hq.vm.share_folder "puppetlabs_stdlib", "/srv/puppet_modules/stdlib", "modules/puppetlabs-stdlib/"

    hq.vm.provision :puppet, :pp_path => "/srv/vagrant-puppet" do |puppet|
      puppet.options = [ "--modulepath", "/srv/puppet_modules", "--certname gitlab_server"]
      logging = ENV['logging']
      puppet.options << "--#{logging}" if ["verbose","debug"].include?(logging)
      puppet.manifests_path = "examples"
      puppet.manifest_file = "gitlab.pp"
    end
  end
end
