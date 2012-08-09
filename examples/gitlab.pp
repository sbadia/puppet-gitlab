# Configure a gitlab server (gitlab.domain.tld)
node /gitlab_server/ {
  class {
    'gitlab':
      git_user          => 'git',
      git_home          => '/home/git',
      git_email         => 'notifs@toto.fr',
      git_comment       => 'GIT control version',
      # Default provider for ssh keys is 'source'
      # you can use also   => 'puppet:///modules/gitlab/file'
      # fileserving on http doesn't work yet (http://projects.puppetlabs.com/issues/5783)
      # If you choose ssh_key_provider = 'content'
      # you can use directly => 'ssh-rsa AAA...'
      git_admin_pubkey  => '/srv/vagrant-puppet/manifests/gitlab_testing.pub',
      git_admin_privkey => '/srv/vagrant-puppet/manifests/gitlab_testing.priv',
      gitlab_user       => 'tig',
      gitlab_home       => '/home/gitlab',
      gitlab_comment    => 'GITLab'
  }
}
