# Class:: gitlab::pre
#
#
class gitlab::pre {
  package {
    ['git','git-core','wget','curl','redis-server',
      'openssh-server','python-pip','libicu-dev',
      'libxml2-dev','libxslt1-dev','python-dev']:
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

  case $::osfamily {
    'Debian': {
      case $::lsbdistcodename {
        # Need to install a fresh ruby version…
        'squeeze','precise': {
          package {
            ['checkinstall','libcurl4-openssl-dev','libreadline6-dev',
            'libssl-dev','build-essential','zlib1g-dev','libyaml-dev']:
              ensure => installed;
          }

          exec {
            'Get Ruby 1.9.3':
              command     => 'wget http://ftp.ruby-lang.org/pub/ruby/1.9/ruby-1.9.3-p194.tar.gz',
              path        => '/usr/sbin:/sbin:/usr/bin:/bin',
              cwd         => '/root',
              user        => root,
              logoutput   => 'on_failure',
              unless      => 'test -f /root/ruby-1.9.3-p194.tar.gz';
            'Untar Ruby 1.9.3':
              command     => 'tar xfz ruby-1.9.3-p194.tar.gz',
              path        => '/usr/sbin:/sbin:/usr/bin:/bin',
              cwd         => '/root',
              user        => root,
              require     => Exec['Get Ruby 1.9.3'],
              unless      => 'test -d /root/ruby-1.9.3-p194',
              logoutput   => 'on_failure',
              notify      => Exec['Configure and Install Ruby 1.9.3'];
            'Configure and Install Ruby 1.9.3':
              command     => '/bin/sh configure && make && make install',
              cwd         => '/root/ruby-1.9.3-p194/',
              path        => '/usr/sbin:/sbin:/usr/bin:/bin',
              user        => root,
              timeout     => 900,
              require     => Exec['Untar Ruby 1.9.3'],
              logoutput   => 'on_failure',
              refreshonly => true;
          }
        } # Squeeze, Precise
        default: {
          # Assuming default ruby 1.9.3 (wheezy,quantal)
          package {
            ['ruby','ruby-dev','rubygems','rake']:
              ensure => installed;
          }
        } # Default
      } # Case:: $::operatingsystem
    } # Debian
    default: {
      err "${osfamily} not supported yet"
    }
  } # Case:: $::osfamily
} # Class:: gitlab::pre
