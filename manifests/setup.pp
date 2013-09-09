# Class:: gitlab::setup
#
#
class gitlab::setup inherits gitlab {
  File {
    owner     => $git_user,
    group     => $git_user,
  }

  # user
  user { $git_user:
    ensure   => present,
    shell    => '/bin/bash',
    password => '*',
    home     => $git_home,
    comment  => $git_comment,
    system   => true,
  }

  sshkey { 'localhost':
    ensure       => present,
    host_aliases => $::fqdn,
    key          => $::sshrsakey,
    type         => 'ssh-rsa',
  }

  file { "${git_home}/.gitconfig":
    ensure    => file,
    content   => template('gitlab/git.gitconfig.erb'),
    mode      => '0644',
  }

  # directories
  file { $git_home:
    ensure => directory,
    mode   => "0755",
  }

  file { "${git_home}/gitlab-satellites":
    ensure    => directory,
    mode      => "0755",
  }
}
