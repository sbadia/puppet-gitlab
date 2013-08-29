# Class:: gitlab::pre
#
#
class gitlab::pre {

  include gitlab

  $git_home       = $gitlab::git_home
  $git_user       = $gitlab::git_user
  $git_comment    = $gitlab::git_comment
  $gitlab_dbtype  = $gitlab::gitlab_dbtype

  user {
    $git_user:
      ensure     => present,
      shell      => '/bin/bash',
      password   => '*',
      home       => $git_home,
      comment    => $git_comment,
      system     => true;
  }

  file {
    $git_home:
      ensure  => directory,
      owner   => $git_user,
      group   => $git_user,
      require => User[$git_user],
      mode    => '0755',
  }

  # try and decide about the family here,
  # deal with version/dist specifics within the class
  case $::osfamily {
    'Debian': {
      $db_packages = $gitlab_dbtype ? {
        mysql => ['libmysql++-dev','libmysqlclient-dev'],
        pgsql => ['libpq-dev', 'postgresql-client'],
      }

      file {
        '/usr/bin/python2':
          ensure => link,
          target => '/usr/bin/python';
      }

      package {
        ['libicu-dev','python2.7','python-docutils',
          'libxml2-dev','libxslt1-dev','python-dev']:
            ensure  => installed;
      }

      if !defined(Package['git-core']) {
        package { 'git-core': ensure => present; }
      }
      if !defined(Package['postfix']) {
        package { 'postfix': ensure => present; }
      }
    } # Debian pre-requists
    'Redhat': {
      $db_packages = $gitlab_dbtype ? {
        mysql => ['mysql-devel'],
        pgsql => ['postgresql-devel'],
      }

      package {
        ['perl-Time-HiRes',
          'libicu-devel','libxml2-devel','libxslt-devel',
          'python-devel','libcurl-devel','readline-devel','openssl-devel',
          'zlib-devel','libyaml-devel']:
            ensure   => latest,
            provider => yum;
      }

    } # Redhat pre-requists
    default: {
      err "${::osfamily} not supported yet"
    }
  }

  package {
    $db_packages:
      ensure   => installed;
  }

  if !defined(Package['openssh-server']) {
    package { 'openssh-server': ensure => present; }
  }
  if !defined(Package['git']) {
    package { 'git': ensure => present; }
  }
  if !defined(Package['curl']) {
    package { 'curl': ensure => present; }
  }
} # Class:: gitlab::pre
