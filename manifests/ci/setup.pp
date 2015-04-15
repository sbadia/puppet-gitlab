# Class:: gitlab::ci::setup
#
#
class gitlab::ci::setup inherits gitlab::ci {

  include ::git

  File {
    owner => $ci_user,
    group => $ci_user,
  }

  # user
  user { $ci_user:
    ensure     => present,
    shell      => '/bin/bash',
    password   => '*',
    home       => $ci_home,
    comment    => $ci_comment,
    system     => true,
    managehome => true,
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
          if $::operatingsystemmajrelease >= 7 {
            $mysql_devel_package = 'mariadb-devel'
          } else {
            $mysql_devel_package = 'mysql-devel'
          }
          ensure_packages([$mysql_devel_package])
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

  # By default, puppet-rbenv sets ~/.profile to load rbenv, which is
  # read when bash is invoked as an interactive login shell, but we
  # also need ~/.bashrc to load rbenv (which is read by interactive
  # but non-login shells). This works, but may not be the best
  # solution, please see issue #114 if you have a better solution.
  file { "${ci_home}/.bashrc":
    ensure  => file,
    content => "source ${ci_home}/.rbenvrc",
    require => Rbenv::Install[$ci_user],
  }

  rbenv::install { $ci_user:
    group   => $ci_user,
    home    => $ci_home,
    require => User[$ci_user],
  }

  rbenv::compile { 'gitlabci/ruby':
    user   => $ci_user,
    home   => $ci_home,
    ruby   => $gitlab_ruby_version,
    global => true,
    notify => Exec['install gitlab-ci'],
  }

}
