# Configure a gitlab server (gitlab.domain.tld)
node /gitlab_server/ {

  $gitlab_dbname  = 'gitlab_prod'
  $gitlab_dbuser  = 'labu'
  $gitlab_dbpwd   = 'labpass'

  # git://github.com/puppetlabs/puppet-postgresql.git
  include 'postgresql::server'

  class {
    'postgres':
      charset => 'UTF8',
      locale  => 'en_US',
  }->
  class {
    'postgresql::server':
      config_hash => {
        'ip_mask_allow_all_users'    => '0.0.0.0/0',
        'listen_addresses'           => '*',
      },
  }

  postgresql::db {
    $gitlab_dbname:
      user     => $gitlab_dbuser,
      password => $gitlab_dbpwd,
  }

  class {
    'gitlab':
      git_user          => 'git',
      git_home          => '/home/git',
      git_email         => 'notifs@foobar.fr',
      git_comment       => 'GIT control version',
      # Default provider for ssh keys is 'source'
      # you can use also   => 'puppet:///modules/gitlab/file'
      # fileserving on http doesn't work yet
      # see bug http://projects.puppetlabs.com/issues/5783
      # If you choose ssh_key_provider = 'content'
      # you can use directly => 'ssh-rsa AAA...'
      git_admin_pubkey  => '/srv/vagrant-puppet/manifests/gitlab_testing.pub',
      git_admin_privkey => '/srv/vagrant-puppet/manifests/gitlab_testing.priv',
      gitlab_user       => 'gitlab',
      gitlab_home       => '/home/gitlab',
      gitlab_comment    => 'GITLab Self hosted Git management software',
      # Setup gitlab sources and branch (default to GIT proto)
      gitlab_sources    => 'https://github.com/gitlabhq/gitlabhq.git',
      gitlab_branch     => '4-2-stable',
      gitolite_sources  => 'https://github.com/gitlabhq/gitolite.git',
      gitolite_branch   => 'gl-v320',
      gitlab_dbtype     => 'pgsql',
      gitlab_dbname     => $gitlab_dbname,
      gitlab_dbuser     => $gitlab_dbuser,
      gitlab_dbpwd      => $gitlab_dbpwd,
      ldap_enabled      => false,
  }
}
