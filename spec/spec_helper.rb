require 'puppetlabs_spec_helper/module_spec_helper'
require 'shared_examples'

RSpec.configure do |c|
  c.alias_it_should_behave_like_to :it_configures, 'configures'
  c.alias_it_should_behave_like_to :it_raises, 'raises'

  c.default_facts = {
    :osfamily               => 'Debian',
    :operatingsystem        => 'Debian',
    :kernel                 => 'Linux',
    :lsbdistid              => 'debian',
    :lsbdistcodename        => 'wheezy',
    :operatingsystemrelease => '6.5',
    :fqdn                   => 'gitlab.fooboozoo.fr',
    :processorcount         => '2',
    :sshrsakey              => 'AAAAB3NzaC1yc2EAAAA',
    :concat_basedir         => '/var/lib/puppet/concat'
  }

end
