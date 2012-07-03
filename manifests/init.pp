# == Class: gitlab
#
# === Parameters
#
# [git_home]
# [git_comment]
# [gitlab_home]
# [gitlab_comment]
#
# === Examples
#
# === Authors
#
# Sebastien Badia (<seb@sebian.fr>)
#
# === Copyright
#
# Sebastien Badia © 2012
# Tue Jul 03 20:06:33 +0200 2012

# Class:: gitlab
#
#
class gitlab(
  $git_user       = 'git',
  $git_home       = '/home/git',
  $git_comment    = 'git version control',
  $git_adminkey   = '',
  $gitlab_user    = 'gitlab',
  $gitlab_home    = '/home/gitlab',
  $gitlab_comment = 'gitlab system') {
  case $operatingsystem {
    debian,ubuntu: {
      include "gitlab::gitlab"
    }
    default: {
      err "${operatingsystem} not supported yet"
    }
  } # case
} # Class:: gitlab

# Class:: gitlab::pre
#
#
class gitlab::pre {
  package {
    ["git","git-core","wget","curl","gcc","checkinstall",
     "libxml2-dev","libxslt-dev","sqlite3","libsqlite3-dev",
     "libcurl4-openssl-dev","libreadline-dev","libc6-dev","libssl-dev",
     "libmysql++-dev","make","build-essential","zlib1g-dev","libicu-dev",
     "redis-server","openssh-server","python-dev","python-pip","libyaml-dev",
     "ruby1.9.1","ruby1.9.1-dev"]:
      ensure => installed;
  }

  user {
    $git_user:
      ensure  => present,
      shell   => '/bin/sh',
      home    => $git_home, managehome => true,
      comment => $git_comment, system => true;
    $gitlab_user:
      ensure  => present,
      groups  => 'git', shell => '/bin/bash',
      home    => $gitlab_home, managehome => true,
      comment => $gitlab_comment;
  }
} # Class:: gitlab::pre

# Class:: gitlab::gitolite inherits gitlab::pre
#
#
class gitlab::gitolite inherits gitlab::pre {
  file {
    "/var/cache/debconf/gitolite.preseed":
      content => template('gitlab/gitolite.preseed.erb'),
      ensure  => file,
      before  => Package["gitolite"];
    "${git_home}/${git_user}.pub":
      content => $git_adminkey,
      ensure  => file, owner => git,
      mode    => 644, require => User["${git_user}"];
    "${git_home}/.gitolite.rc":
      source  => "puppet:///modules/gitlab/gitolite-rc",
      ensure  => file,
      owner   => $git_user, group => $git_user, mode => 644,
      require => [Package["gitolite"],User["${git_user}"]];
    "${git_home}/.gitolite/hooks/common/post-receive":
      source  => "puppet:///modules/gitlab/post-receive",
      ensure  => file,
      owner   => $git_user, group => $git_user, mode => 755,
    "${git_home}/.gitconfig":
      source  => template('gitlab/gitolite.gitconfig.erb'),
      ensure  => file,
      owner   => $git_user, group => $git_user, mode => 644,
      require => Package["gitolite"];
  }

  package {
    "gitolite":
      ensure       => installed,
      notify       => Exec["gl-setup gitolite"],
      responsefile => "/var/cache/debconf/gitolite.preseed";
  }

  exec {
    "gl-setup gitolite":
      command     => "/bin/su -c '/usr/bin/gl-setup ${git_home}/${git_user}.pub > /dev/null 2>&1' ${git_user}",
      user        => root,
      require     => [Package["gitolite"],File["${git_home}/.gitconfig"]],
      refreshonly => "true";
  }
} # Class:: gitlab::gitolite inherits gitlab::pre

# Class:: gitlab::gitlab inherits gitlab::gitolite
#
#
class gitlab::gitlab inherits gitlab::gitolite {

} # Class:: gitlab::gitlab inherits gitlab::gitolite
