# Class:: gitlab::package
#
#
class gitlab::package inherits gitlab {
  Exec {
    cwd  => $git_home,
    user => $git_user,
    path => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
  }

  exec { 'download gitlab':
    command   => "git clone -b ${gitlab_branch} ${gitlab_sources} ./gitlab",
    creates   => "${git_home}/gitlab",
  }

  exec { 'download gitlab-shell':
    command   => "git clone -b ${gitlabshell_branch} ${gitlabshell_sources} ./gitlab-shell",
    creates   => "${git_home}/gitlab-shell",
  }
}
