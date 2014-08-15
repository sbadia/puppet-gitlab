# Class:: gitlab::config
#
#
class gitlab::ci::config inherits gitlab::ci {
  File {
    owner => $ci_user,
    group => $ci_user,
  }

  $socket_path = "${ci_home}/gitlab-ci/tmp/sockets/gitlab-ci.socket"
  $root_path = "${ci_home}/gitlab-ci/public"

  if $gitlab_manage_nginx {
    file { '/etc/nginx/conf.d/gitlab-ci.conf':
      ensure  => file,
      content => template('gitlab/nginx-gitlab.conf.erb'),
      owner   => root,
      group   => root,
      mode    => '0644',
    }
  }

  file { '/etc/init.d/gitlab_ci':
    ensure => file,
    source => "${ci_home}/gitlab-ci/lib/support/init.d/gitlab_ci",
    owner  => root,
    group  => root,
    mode   => '0755',
  }

  # directories
  file { [
      "${ci_home}/gitlab-ci/tmp",
      "${ci_home}/gitlab-ci/tmp/pids",
      "${ci_home}/gitlab-ci/tmp/sockets",
      "${ci_home}/gitlab-ci/log",
      "${ci_home}/gitlab-ci/public",
    ]:
    ensure => directory,
    mode   => '0755',
  }
}
