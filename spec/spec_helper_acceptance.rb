require 'beaker-rspec'

hosts.each do |host|
  install_puppet
  on host, "mkdir -p #{host['distmoduledir']}"
end

RSpec.configure do |c|
  # Project root
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  # Readable test descriptions
  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do
    # Install module
    puppet_module_install(:source => proj_root, :module_name => 'gitlab')
    hosts.each do |host|
      on host, puppet('module','install','alup/rbenv'), { :acceptable_exit_codes => [0,1] }
      on host, puppet('module','install','fsalum/redis'), { :acceptable_exit_codes => [0,1] }
      on host, puppet('module','install','jfryman/nginx'), { :acceptable_exit_codes => [0,1] }
      on host, puppet('module','install','evenup/logrotate'), { :acceptable_exit_codes => [0,1] }
      on host, puppet('module','install','puppetlabs-git'), { :acceptable_exit_codes => [0,1] }
      on host, puppet('module','install','puppetlabs-vcsrepo'), { :acceptable_exit_codes => [0,1] }
      on host, puppet('module','install','puppetlabs-mysql', '--version', '2.2'), { :acceptable_exit_codes => [0,1] }
      on host, puppet('module','install','puppetlabs-stdlib'), { :acceptable_exit_codes => [0,1] }
    end
  end
end
