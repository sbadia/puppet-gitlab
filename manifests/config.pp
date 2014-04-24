# Class:: gitlab::config
#
#
class gitlab::config inherits gitlab {
  File {
    owner     => $git_user,
    group     => $git_user,
  }

  # gitlab
  if $gitlab_manage_nginx {
    file { '/etc/nginx/conf.d/gitlab.conf':
      ensure  => file,
      content => template('gitlab/nginx-gitlab.conf.erb'),
      owner   => root,
      group   => root,
      mode    => '0644',
    }
  }

  file { '/etc/default/gitlab':
    ensure  => file,
    content => template('gitlab/gitlab.default.erb'),
    owner   => root,
    group   => root,
    mode    => '0644',
  }

  file { '/etc/init.d/gitlab':
    ensure  => file,
    source  => "${git_home}/gitlab/lib/support/init.d/gitlab",
    owner   => root,
    group   => root,
    mode    => '0755',
    require => File['/etc/default/gitlab'],
  }

  file { '/etc/logrotate.d/gitlab':
      ensure  => file,
      source  => "${git_home}/gitlab/lib/support/logrotate/gitlab",
      owner   => root,
      group   => root,
      mode    => '0644';
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
    ensure => link,
    owner  => root,
    group  => root,
    target => '/usr/bin/python';
  }

  # backup task
  if $gitlab_backup {

    file { '/usr/local/sbin/backup-gitlab.sh':
      ensure  => present,
      content => template('gitlab/backup-gitlab.sh.erb'),
      mode    => '0755',
      owner   => 'root',
      group   => 'root',
    }

    cron { 'gitlab backup':
      command => '/usr/local/sbin/backup-gitlab.sh',
      hour    => $gitlab_backup_time,
      minute  => fqdn_rand(60),
      user    => $git_user,
      require => File['/usr/local/sbin/backup-gitlab.sh'],
    }
  }
}
