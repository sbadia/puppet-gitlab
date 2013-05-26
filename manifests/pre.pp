# Class:: gitlab::pre
#
#
class gitlab::pre {

  include gitlab

  $git_home       = $gitlab::git_home
  $git_user       = $gitlab::git_user
  $git_comment    = $gitlab::git_comment

  user {
    $git_user:
      ensure     => present,
      shell      => '/bin/bash',
      password   => '*',
      home       => $git_home,
      managehome => true,
      comment    => $git_comment,
      system     => true;
  }

  # try and decide about the family here,
  # deal with version/dist specifics within the class
  case $::osfamily {
    'Debian': {
      require gitlab::debian_packages
    }
    'Redhat': {
      require gitlab::redhat_packages
      file {
          $git_home:
          mode    => '0750',
          recurse => false,
          require => User[$git_user];
      }
    }
    default: {
      err "${::osfamily} not supported yet"
    }
  }

} # Class:: gitlab::pre

# Class:: gitlab::redhat_packages
# FIXME: gitlab::redhat_packages not in autoload module layout
#
class gitlab::redhat_packages {

  include gitlab

  $gitlab_dbtype  = $gitlab::gitlab_dbtype

  Package{ ensure => latest, provider => yum, }

  $db_packages = $gitlab_dbtype ? {
    mysql => ['mysql-devel'],
    pgsql => ['postgresql-devel'],
  }

  package {
    $db_packages:
      ensure => installed;
  }

  package {
    [ 'git','perl-Time-HiRes','wget','curl','redis','openssh-server',
      'python-pip','libicu-devel','libxml2-devel','libxslt-devel',
      'python-devel','libcurl-devel','readline-devel','openssl-devel',
      'zlib-devel','libyaml-devel']:
        ensure => installed;
  }

  service {
    'iptables':
      ensure  => stopped,
      enable  => false;
    'redis':
      ensure  => running,
      enable  => true,
      require => Package['redis'];
  }

} # Class:: gitlab::redhat_packages

# Class:: gitlab::debian_packages
# FIXME: gitlab::debian_packages not in autoload module layout
#
class gitlab::debian_packages {

  include gitlab

  $gitlab_dbtype  = $gitlab::gitlab_dbtype
  $git_home       = $gitlab::git_home
  $git_user       = $gitlab::git_user
  $git_admin_pubkey = $gitlab::git_admin_pubkey

  $db_packages = $gitlab_dbtype ? {
    mysql => ['libmysql++-dev','libmysqlclient-dev'],
    pgsql => ['libpq-dev', 'postgresql-client'],
  }

  package {
    $db_packages:
      ensure  => installed;
  }

  package {
    ['git','git-core','wget','curl','redis-server',
      'openssh-server','python-pip','libicu-dev','python2.7',
      'libxml2-dev','libxslt1-dev','python-dev','postfix']:
        ensure  => installed;
  }

  case $::lsbdistcodename {

    precise: {
      package {
        'ruby1.9.3':
          ensure => installed;
      }

      exec {
        'ruby-version':
          command     => '/usr/bin/update-alternatives --set ruby /usr/bin/ruby1.9.1',
          user        => root,
          logoutput   => 'on_failure',
          require     => Package['ruby1.9.3'];
        'gem-version':
          command     => '/usr/bin/update-alternatives --set gem /usr/bin/gem1.9.1',
          user        => root,
          logoutput   => 'on_failure',
          require     => Package['ruby1.9.3'];
      }
    }

    default: {
      # Assuming default ruby 1.9.x (wheezy,quantal,raring)
      package {
        ['ruby','ruby-dev','rubygems','rake']:
          ensure  => installed;
      }
    } # Default
  } # Case:: $::operatingsystem

  service {
    'redis-server':
      ensure  => running,
      enable  => true,
      require => Package['redis-server'];
  }

} # Class:: gitlab::debian_packages
