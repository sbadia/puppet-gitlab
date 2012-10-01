# Class:: gitlab::pre
#
#
class gitlab::pre {
  package {
    ['git','git-core','wget','curl','redis-server',
      'openssh-server','python-pip','ruby','ruby-dev','rubygems',
      'rake','libicu-dev','libxml2-dev','libxslt-dev','python-dev']:
      ensure => installed;
  }

  case $gitlab_dbtype {
    'sqlite': {
      package {
        ['libsqlite3-dev','sqlite3']:
          ensure => installed;
      }
    } # Sqlite
    'mysql': {
      package {
        ['libmysql++-dev','mysql-server','mysql-client','libmysqlclient-dev']:
          ensure => installed;
      }
    } # Mysql
    default: {
      err "${gitlab_dbtype} not supported yet"
    }
  } # Case:: $gitlab_dbtype

  user {
    $git_user:
      ensure     => present,
      shell      => '/bin/sh',
      home       => $git_home,
      managehome => true,
      comment    => $git_comment,
      system     => true;
    $gitlab_user:
      ensure     => present,
      groups     => $git_user,
      shell      => '/bin/bash',
      home       => $gitlab_home,
      managehome => true,
      comment    => $gitlab_comment,
      require    => User[$git_user];
  }
} # Class:: gitlab::pre
