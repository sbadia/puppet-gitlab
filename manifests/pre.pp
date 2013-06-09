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

      package {
        ['git-core',
          'libicu-dev','python2.7',
          'libxml2-dev','libxslt1-dev','python-dev','postfix']:
            ensure  => installed;
      }

      # Ruby settings
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
        } # Ubuntu precise
        default: {
          # Assuming default ruby 1.9.x (wheezy,quantal,raring)
          package {
            ['ruby','ruby-dev','rake']:
              ensure  => installed;
          }
        } # Default
      } # Case:: $::operatingsystem (ruby settings)
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

  package {
    ['openssh-server','git','curl']:
      ensure => installed;
  }

} # Class:: gitlab::pre
