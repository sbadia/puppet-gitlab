# Class:: gitlab::setup
#
#
class gitlab::setup {
  File {
    owner     => $gitlab::params::git_user,
    group     => $gitlab::params::git_user,
  }

  # user
  user { $gitlab::params::git_user:
    ensure   => present,
    shell    => '/bin/bash',
    password => '*',
    home     => $gitlab::params::git_home,
    comment  => $gitlab::params::git_comment,
    system   => true,
  }

  sshkey { 'localhost':
    ensure       => present,
    host_aliases => $::fqdn,
    key          => $::sshrsakey,
    type         => 'ssh-rsa',
  }

  file { "${gitlab::params::git_home}/.gitconfig":
    ensure    => file,
    content   => template('gitlab/git.gitconfig.erb'),
    mode      => '0644',
  }

  # directories
  file { $gitlab::params::git_home:
    ensure => directory,
    mode   => '0755',
  }

  file { "${gitlab::params::git_home}/gitlab-satellites":
    ensure    => directory,
    mode      => '0755',
  }

  # database dependencies
  case $::osfamily {
    'Debian': {
      case $gitlab_dbtype {
        'mysql': {
          ensure_packages(['libmysql++-dev','libmysqlclient-dev'])
        }
        'pgsql': {
          ensure_packages(['libpq-dev','postgresql-client'])
        }
        default: {
          fail("unknow dbtype (${gitlab_dbtype})")
        }
      }
    }
    'RedHat': {
      case $gitlab_dbtype {
        'mysql': {
          ensure_packages(['mysql-devel'])
        }
        'pgsql': {
          ensure_packages(['postgresql-devel'])
        }
        default: {
          fail("unknow dbtype (${gitlab_dbtype})")
        }
      }
    }
    default: {
      fail("${::osfamily} not supported yet")
    }
  } # Case $::osfamily

  # system packages
  package { 'bundler':
    ensure    => installed,
    provider  => gem,
  }

  ensure_packages($gitlab::params::system_packages)
  package { 'charlock_holmes':
    ensure    => '0.6.9.4',
    provider  => gem,
  }

  # other packages
  ensure_packages(['git-core','postfix','curl'])
}
