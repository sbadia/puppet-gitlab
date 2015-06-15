# Class:: gitlab::config
#
#
class gitlab::config inherits gitlab {
  File {
    owner => $git_user,
    group => $git_group,
  }

  $socket_path = "${git_home}/gitlab/tmp/sockets/gitlab.socket"
  $root_path = "${git_home}/gitlab/public"

  # gitlab
  if $gitlab_manage_nginx {
    file { '/etc/nginx/conf.d/gitlab.conf':
      ensure  => file,
      content => template('gitlab/nginx-gitlab.conf.erb'),
      owner   => root,
      group   => root,
      mode    => '0644',
      notify  => Service[$gitlab::webserver_service_name],
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
      ensure => file,
      source => "${git_home}/gitlab/lib/support/logrotate/gitlab",
      owner  => root,
      group  => root,
      mode   => '0644';
  }

  # directories
  file { [
      "${git_home}/gitlab/tmp",
      "${git_home}/gitlab/tmp/pids",
      "${git_home}/gitlab/tmp/sockets",
      "${git_home}/gitlab/public",
      "${git_home}/gitlab/public/uploads",
    ]:
    ensure => directory,
    mode   => '0755',
  }

  #gitlab does not provide an option to configure a log directory, so create a symlink to
  #the desired folder if specified (otherwise, simply ensure the default log folder is there)
  $gitlab_log_path_type = $gitlab_log_folder ? {
    undef   => 'directory',
    default => 'link',
  }
  file { "${git_home}/gitlab/log":
    ensure => $gitlab_log_path_type,
    target => $gitlab_log_folder,
    mode   => '0755',
    force  => true, #for the conversion to link
  }

  # backup task
  $backup_file = '/usr/local/sbin/backup-gitlab.sh'

  $backup_ensure = $gitlab_backup? {
    true    => present,
    default => absent,
  }

  file { $backup_file:
    ensure  => $backup_ensure,
    content => template('gitlab/backup-gitlab.sh.erb'),
    mode    => '0755',
    owner   => 'root',
    group   => 'root',
  }

  cron { 'gitlab backup':
    ensure  => $backup_ensure,
    command => $backup_file,
    hour    => $gitlab_backup_time,
    minute  => fqdn_rand(60),
    user    => $git_user,
  }
}
