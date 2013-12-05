# Class:: gitlab::package
#
#
class gitlab::package inherits gitlab {
  Vcsrepo {
    ensure   => $ensure,
    provider => 'git',
    user     => $git_user,
  }

  vcsrepo { "${git_home}/gitlab":
    source   => $gitlab_sources,
    revision => $gitlab_branch,
  }
  vcsrepo { "${git_home}/gitlab-shell":
    source   => $gitlabshell_sources,
    revision => $gitlabshell_branch,
  }
}
