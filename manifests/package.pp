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

  # Download and build gitlab-git-http-server. 
  # Not everything belongs here, but it seems better to keep everything together for now, while
  # we still support GitLab 7.x installation (which won't want this) 
  if $gitlab_git_http_server_branch {
	  ensure_packages(['golang'])

	  vcsrepo { "${git_home}/gitlab-git-http-server":
	    source   => $gitlab_git_http_server_sources,
	    revision => $gitlab_git_http_server_branch,
	  }

	  exec { "Build gitlab-git-http-server":
	    command     => "make",
	    cwd         => "${git_home}/gitlab-git-http-server",
	    user        => $git_user,
	    path        => $exec_path,
	    environment => $exec_environment,
	    refreshonly => true,
	    require     => Package['golang'],
	    subscribe   => Vcsrepo["${git_home}/gitlab-git-http-server"],
	  }
  }
}
