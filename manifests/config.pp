# Class:: gitlab::config
#
#
class gitlab::config inherits gitlab {
  File {
    owner     => $git_user,
    group     => $git_user,
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
      "${git_home}/gitlab/tmp",
      "${git_home}/gitlab/tmp/pids",
      "${git_home}/gitlab/tmp/sockets",
      "${git_home}/gitlab/log",
      "${git_home}/gitlab/public",
      "${git_home}/gitlab/public/uploads"
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
