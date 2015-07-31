# Class:: gitlab::setup
#
#
class gitlab::setup inherits gitlab {

  include ::git

  File {
    owner => $git_user,
    group => $git_group,
  }

  # user
  if($gitlab_manage_user)
  {
    user { $git_user:
      ensure   => present,
      shell    => '/bin/bash',
      password => '*',
      home     => $git_home,
      comment  => $git_comment,
      system   => true,
    }
  }

  sshkey { 'localhost':
    ensure       => present,
    host_aliases => $::fqdn,
    key          => $::sshrsakey,
    type         => 'ssh-rsa',
  }

  file { "${git_home}/.gitconfig":
    ensure  => file,
    content => template('gitlab/git.gitconfig.erb'),
    mode    => '0644',
  }

  # directories
  if($gitlab_manage_home)
  {
    file { $git_home:
      ensure => directory,
      mode   => '0755',
    }
  }

  file { "${gitlab_satellitedir}/gitlab-satellites":
    ensure => directory,
    mode   => '0750',
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
          if (versioncmp($::operatingsystemmajrelease, '7') >= 0) {
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

  # dev. dependencies
  ensure_packages($gitlab::system_packages)

  if ($gitlab_manage_rbenv) {
    rbenv::install { $git_user:
      group => $git_group,
      home  => $git_home,
    }

    # By default, puppet-rbenv sets ~/.profile to load rbenv, which is
    # read when bash is invoked as an interactive login shell, but we
    # also need ~/.bashrc to load rbenv (which is read by interactive
    # but non-login shells). This works, but may not be the best
    # solution, please see issue #114 if you have a better solution.
    file { "${git_home}/.bashrc":
      ensure  => link,
      target  => "${git_home}/.profile",
      require => Rbenv::Install[$git_user],
    }

    rbenv::compile { 'gitlab/ruby':
      user   => $git_user,
      group  => $git_group,
      home   => $git_home,
      ruby   => $gitlab_ruby_version,
      global => true,
      notify => [
        Exec['install gitlab-shell'],
        Exec['install gitlab'],
      ],
    }

    #Gitlab <= 6.3 requires us to install the charlock_holmes gem
    rbenv::gem { 'charlock_holmes':
      ensure => '0.6.9.4',
      user   => $git_user,
      home   => $git_home,
      ruby   => $gitlab_ruby_version,
    }
  } #end if ($gitlab_manage_rbenv)

  # other packages
  if $gitlab_ensure_curl {
    ensure_packages(['curl'])
  }

  if $gitlab_ensure_postfix {
    ensure_packages(['postfix'])
  }
}
