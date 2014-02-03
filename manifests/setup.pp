# Class:: gitlab::setup
#
#
class gitlab::setup inherits gitlab {
  File {
    owner     => $git_user,
    group     => $git_user,
  }

  # user
  user { $git_user:
    ensure   => present,
    shell    => '/bin/bash',
    password => '*',
    home     => $git_home,
    comment  => $git_comment,
    system   => true,
  }

  sshkey { 'localhost':
    ensure       => present,
    host_aliases => $::fqdn,
    key          => $::sshrsakey,
    type         => 'ssh-rsa',
  }

  file { "${git_home}/.gitconfig":
    ensure    => file,
    content   => template('gitlab/git.gitconfig.erb'),
    mode      => '0644',
  }

  # directories
  file { $git_home:
    ensure => directory,
    mode   => '0755',
  }

  file { "${git_home}/gitlab-satellites":
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

  # dev. dependencies
  ensure_packages($system_packages)

  rbenv::install { $git_user:
    group   => $git_user,
    home    => $git_home,
    rc      => '.bashrc', # read by non-interactive shells (e.g. ssh)
  }

  rbenv::compile { 'gitlab/2.0.0-p353':
    user   => $git_user,
    home   => $git_home,
    ruby   => '2.0.0-p353',
    global => true,
    notify => [ Exec['install gitlab-shell'],
                Exec['install gitlab'] ],
  }

  rbenv::gem { 'charlock_holmes':
    user   => $git_user,
    home   => $git_home,
    ruby   => '2.0.0-p353',
    ensure => '0.6.9.4',
  }

  # other packages
  ensure_packages([$git_package_name,'postfix','curl'])
}
