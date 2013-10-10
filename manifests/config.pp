# Class:: gitlab::config
#
#
class gitlab::config {
  File {
    owner     => $gitlab::params::git_user,
    group     => $gitlab::params::git_user,
  }

  # gitlab
  file { '/etc/nginx/conf.d/gitlab.conf':
    ensure  => file,
    content => template('gitlab/nginx-gitlab.conf.erb'),
    owner   => root,
    group   => root,
    mode    => '0644',
  }

  file { '/etc/init.d/gitlab':
    ensure  => file,
    content => template('gitlab/gitlab.init.erb'),
    owner   => root,
    group   => root,
    mode    => '0755',
  }

  # directories
  file { [
      "${gitlab::params::git_home}/gitlab/tmp",
      "${gitlab::params::git_home}/gitlab/tmp/pids",
      "${gitlab::params::git_home}/gitlab/tmp/sockets",
      "${gitlab::params::git_home}/gitlab/log",
      "${gitlab::params::git_home}/gitlab/public",
      "${gitlab::params::git_home}/gitlab/public/uploads"
    ]:
    ensure    => directory,
    mode      => '0755',
  }

  # symlink fix for python
  file { '/usr/bin/python2':
    ensure  => link,
    target  => '/usr/bin/python',
  }
}
