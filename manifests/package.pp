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
    notify   => Service['gitlab'], # restart service if code has been updated
  }
  vcsrepo { "${git_home}/gitlab-shell":
    source   => $gitlabshell_sources,
    revision => $gitlabshell_branch,
  }

  # Download and build gitlab-workhorse. 
  # Not everything belongs here, but it seems better to keep everything together for now, while
  # we still support GitLab 7.x installation (which won't want this) 
  if $gitlab_workhorse_branch {
	  ensure_packages(['golang'])

	  vcsrepo { "${git_home}/gitlab-workhorse":
	    source   => $gitlab_workhorse_sources,
	    revision => $gitlab_workhorse_branch,
	  }

	  exec { "Build gitlab-workhorse":
	    command     => "make",
	    cwd         => "${git_home}/gitlab-workhorse",
	    user        => $git_user,
	    path        => $exec_path,
	    environment => $exec_environment,
	    refreshonly => true,
	    require     => Package['golang'],
	    subscribe   => Vcsrepo["${git_home}/gitlab-workhorse"],
	    notify      => Service['gitlab'], # restart service if code has been updated
	  }
	  
	  #Gitlab 8.0 and 8.1 expect gitlab-git-http-server instead
	  file {
	    "${git_home}/gitlab-git-http-server":
        ensure => "directory",
        owner  => $git_user,
        group  => $git_group;
      "${git_home}/gitlab-git-http-server/gitlab-git-http-server":
        ensure => "link",
        target => "${git_home}/gitlab-workhorse/gitlab-workhorse", 
        owner  => $git_user,
        group  => $git_group;
	  }
  }
}
