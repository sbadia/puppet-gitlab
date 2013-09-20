# Class:: gitlab::package
#
#
class gitlab::package {
  Exec {
    cwd  => $gitlab::params::git_home,
    user => $gitlab::params::git_user,
    path => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
  }

  exec { 'download gitlab':
    command   => "git clone -b ${gitlab::params::gitlab_branch} ${gitlab::params::gitlab_sources} ./gitlab",
    creates   => "${gitlab::params::git_home}/gitlab",
  }

  exec { 'download gitlab-shell':
    command   => "git clone -b ${gitlab::params::gitlabshell_branch} ${gitlab::params::gitlabshell_sources} ./gitlab-shell",
    creates   => "${gitlab::params::git_home}/gitlab-shell",
  }
}
