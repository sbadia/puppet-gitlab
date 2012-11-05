# Configure a gitlab server with LDAP auth (gitlab.domain.tld)
node /gitlab_server/ {
  class {
    'gitlab':
      git_user          => 'git',
      git_home          => '/home/git',
      git_email         => 'notifs@foobar.fr',
      git_comment       => 'GIT control version',
      # Default provider for ssh keys is 'source'
      # you can use also   => 'puppet:///modules/gitlab/file'
      # fileserving on http doesn't work yet (http://projects.puppetlabs.com/issues/5783)
      # If you choose ssh_key_provider = 'content'
      # you can use directly => 'ssh-rsa AAA...'
      git_admin_pubkey  => '/srv/vagrant-puppet/manifests/gitlab_testing.pub',
      git_admin_privkey => '/srv/vagrant-puppet/manifests/gitlab_testing.priv',
      gitlab_user       => 'gitlab',
      gitlab_home       => '/home/gitlab',
      gitlab_comment    => 'GITLab is awesome',
      #FIXME mysql db not yet created, see https://github.com/sbadia/puppet-gitlab/issues/11
      gitlab_dbtype     => 'mysql',
      ldap_enabled      => true,
      ldap_host         => 'ldap.foobar.fr',
      ldap_base         => 'dc=foobar,dc=fr',
      ldap_uid          => 'uid',
      ldap_port         => '636',
      ldap_method       => 'ssl',
  }
}
