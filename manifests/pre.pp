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
      shell      => '/bin/false',
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
  include mysql

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

  class { 'mysql::server': }

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
  include mysql

  $gitlab_dbtype  = $gitlab::gitlab_dbtype
  $git_home       = $gitlab::git_home
  $git_user       = $gitlab::git_user
  $git_admin_pubkey = $gitlab::git_admin_pubkey

  exec {
    'apt-get update':
      before      => Class['mysql'],
      command     => '/usr/bin/apt-get update';
  }

  class { 'mysql::server': require => Exec['apt-get update'], }

  $db_packages = $gitlab_dbtype ? {
    mysql => ['libmysql++-dev','libmysqlclient-dev'],
    pgsql => ['libpq-dev', 'postgresql-client'],
  }

  package {
    $db_packages:
      ensure  => installed,
      require => Exec['apt-get update']
  }

  package {
    ['git','git-core','wget','curl','redis-server',
      'openssh-server','python-pip','libicu-dev','python2.7',
      'libxml2-dev','libxslt1-dev','python-dev','postfix']:
        ensure  => installed,
        require => Exec['apt-get update'],
  }

  case $::lsbdistcodename {
    # Need to install a fresh ruby version...
    'squeeze': {
      package {
        ['checkinstall','libcurl4-openssl-dev','libreadline-dev','libssl-dev',
        'build-essential','zlib1g-dev','libyaml-dev','libc6-dev','libgdbm-dev',
        'libncurses5-dev','libffi-dev','libcurl4-openssl-dev','libicu-dev']:
          ensure  => installed,
          require => Exec['apt-get update'];
      }

      exec {
        'Get Ruby 1.9.3':
          command     => 'wget http://ftp.ruby-lang.org/pub/ruby/1.9/ruby-1.9.3-p392.tar.gz',
          path        => '/usr/sbin:/sbin:/usr/bin:/bin',
          cwd         => '/root',
          user        => root,
          logoutput   => 'on_failure',
          require     => Package['checkinstall','libcurl4-openssl-dev',
                                  'libreadline6-dev','libssl-dev',
                                  'build-essential','zlib1g-dev','libyaml-dev',
                                  'libc6-dev'],
          unless      => 'test -f /root/ruby-1.9.3-p392.tar.gz';
        'Untar Ruby 1.9.3':
          command     => 'tar xfz ruby-1.9.3-p392.tar.gz',
          path        => '/usr/sbin:/sbin:/usr/bin:/bin',
          cwd         => '/root',
          user        => root,
          require     => Exec['Get Ruby 1.9.3'],
          unless      => 'test -d /root/ruby-1.9.3-p392',
          logoutput   => 'on_failure',
          notify      => Exec['Configure and Install Ruby 1.9.3'];
        'Configure and Install Ruby 1.9.3':
          command     => '/bin/sh configure && make && make install',
          cwd         => '/root/ruby-1.9.3-p392/',
          path        => '/usr/sbin:/sbin:/usr/bin:/bin',
          user        => root,
          timeout     => 900,
          require     => Exec['Untar Ruby 1.9.3'],
          logoutput   => 'on_failure',
          refreshonly => true;
      }
    } # Squeeze, Precise
    default: {
      # Assuming default ruby 1.9.3 (wheezy,quantal,precise)
      package {
        ['ruby','ruby-dev','rubygems','rake']:
          ensure  => installed,
          require => Exec['apt-get update'];
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
