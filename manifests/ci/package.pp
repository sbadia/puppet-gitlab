# Class:: gitlab::ci::package
#
#
class gitlab::ci::package inherits gitlab::ci {
  Vcsrepo {
    ensure   => $ensure,
    provider => 'git',
    user     => $ci_user,
  }

  vcsrepo { "${ci_home}/gitlab-ci":
    source   => $gitlabci_sources,
    revision => $gitlabci_branch,
  }
}
