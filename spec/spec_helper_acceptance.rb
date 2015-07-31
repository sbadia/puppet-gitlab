require 'beaker-rspec'
require 'beaker/puppet_install_helper'

run_puppet_install_helper

RSpec.configure do |c|
  # Project root
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))
  modname = JSON.parse(open('metadata.json').read)['name'].split('-')[1]

  # Readable test descriptions
  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do

    # Install module
    #
    puppet_module_install(:source => proj_root, :module_name => modname)
    hosts.each do |host|
      on host, puppet('module','install','alup/rbenv'), { :acceptable_exit_codes => [0,1] }
      on host, puppet('module','install','fsalum/redis'), { :acceptable_exit_codes => [0,1] }
      on host, puppet('module','install','jfryman/nginx'), { :acceptable_exit_codes => [0,1] }
      on host, puppet('module','install','evenup/logrotate'), { :acceptable_exit_codes => [0,1] }
      on host, puppet('module','install','puppet/nodejs'), { :acceptable_exit_codes => [0,1] }
      # FIXME https://github.com/puppet-community/puppet-nodejs/pull/152
      on host, puppet('module','install','treydock/gpg_key'), { :acceptable_exit_codes => [0,1] }
      on host, puppet('module','install','puppetlabs-git'), { :acceptable_exit_codes => [0,1] }
      on host, puppet('module','install','puppetlabs-vcsrepo'), { :acceptable_exit_codes => [0,1] }
      on host, puppet('module','install','puppetlabs-mysql'), { :acceptable_exit_codes => [0,1] }
      on host, puppet('module','install','puppetlabs-stdlib'), { :acceptable_exit_codes => [0,1] }

      # List modules installed to help with debugging
      on host, puppet('module','list'), { :acceptable_exit_codes => [0] }
    end
  end
end
