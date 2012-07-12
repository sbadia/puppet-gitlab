# == Class: gitlab
#
# === Parameters
#
# [git_user] Name of the gitolite user (for ssh)
# [git_home] Home directory for gitolite repository
# [git_email] Email address for gitolite user
# [git_comment] Gitolite user comment
# [git_adminkey] Gitolite admin ssh key (required)
# [gitlab_user] Name of gitlab user
# [gitlab_home] Home directory for gitlab installation
# [gitlab_comment] Gitlab comment
# [gitlab_sources] Gitlab sources (github)
# [gitlab_dbtype] Gitlab database type (sqlite/mysql)
#
# === Examples
#
# See examples/gitlab.pp
#
# node /gitlab/ {
#   class {
#     'gitlab':
#       git_adminkey => 'ssh-rsa AAA...'
#   }
# }
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
  $git_email      = 'git@someserver.net',
  $git_comment    = 'git version control',
  $git_adminkey   = '#Not configured',
  $gitlab_user    = 'gitlab',
  $gitlab_home    = '/home/gitlab',
  $gitlab_comment = 'gitlab system',
  $gitlab_sources = 'git://github.com/gitlabhq/gitlabhq.git',
  $gitlab_dbtype  = 'sqlite') {
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
      owner   => $git_user, group => $git_user, mode => 755;
    "${git_home}/.gitconfig":
      content => template('gitlab/gitolite.gitconfig.erb'),
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
      require     => [Package["gitolite"],File["${git_home}/.gitconfig"],File["${git_home}/${git_user}.pub"]],
      refreshonly => "true";
  }
} # Class:: gitlab::gitolite inherits gitlab::pre

# Class:: gitlab::gitlab inherits gitlab::gitolite
#
#
class gitlab::gitlab inherits gitlab::gitolite {
  package {
    ["charlock_holmes","bundler"]:
      ensure   => installed,
      provider => gem;
    "pygments":
      ensure  => installed,
      provider => pip;
  }

  exec {
    "Get gitlab":
      command     => "git clone -b stable ${gitlab_sources} ./gitlab",
      cwd         => $gitlab_home,
      path        => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
      user        => $gitlab_user,
      require     => Package["gitolite"];
    "Install gitlab":
      command     => "bundle install --without development test --deployment",
      cwd         => "${gitlab_home}/gitlab",
      path        => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
      user        => $gitlab_user,
      require     => Exec["Get gitlab"],
      refreshonly => true;
    "Setup gitlab DB":
      command     => "bundle exec rake gitlab:app:setup RAILS_ENV=production",
      cwd         => "${gitlab_home}/gitlab",
      path        => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
      user        => $gitlab_user,
      require     => [Exec["Install gitlab"],File["${gitlab_home}/gitlab/config/database.yml"]],
      refreshonly => true;
  }

  file {
    "${gitlab_home}/gitlab/config/database.yml":
      ensure  => link,
      target  => "${gitlab_home}/gitlab/config/database.yml.${gitlab_dbtype}",
      require => [Exec["Get gitlab"],File["${gitlab_home}/gitlab/config/gitlab.yml"]];
    "${gitlab_home}/gitlab/config/gitlab.yml":
      ensure  => link,
      target  => "${gitlab_home}/gitlab/config/gitlab.yml.example",
      require => Exec["Get gitlab"],
      notify  => Exec["Setup gitlab DB"];
  }

  #TODO: add nginx config.
  #FIXME: untested…

  file {
    "/etc/init.d/gitlab":
      source  => "puppet:///modules/gitlab/gitlab.init",
      ensure  => file,
      owner   => root, group => root, mode => 0755,
      notify  => Service["gitlab"],
      require => Exec["Setup gitlab DB"];
  }

  service {
    "gitlab":
      ensure  => running,
      require => File["/etc/init.d/gitlab"],
      enabled => true;
  }
} # Class:: gitlab::gitlab inherits gitlab::gitolite
