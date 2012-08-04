# Class:: gitlab::pre
#
#
class gitlab::pre {
  package {
    ["git","git-core","wget","curl","sqlite3","redis-server",
     "openssh-server","python-pip","ruby","ruby-dev","rubygems",
     "rake","libicu-dev","libxml2-dev","libxslt1-dev","libmysqlclient-dev",
     "libsqlite3-dev","python-dev"]:
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
      groups  => $git_user, shell => '/bin/bash',
      home    => $gitlab_home, managehome => true,
      comment => $gitlab_comment,
      require => User["${git_user}"];
  }
} # Class:: gitlab::pre
