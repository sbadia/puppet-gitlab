# Class:: gitlab::dependency inherits gitlab
#
#
class gitlab::dependency inherits gitlab {

  include logrotate

  # database dependencies
  case $gitlab_dbtype {
    'mysql': {
      case $::osfamily {
        'Debian': {
          ensure_packages(['libmysql++-dev','libmysqlclient-dev'])
        }
        'RedHat': {
          ensure_packages(['mysql-devel'])
        }
        default: {
          err "${::osfamily} not supported yet for mysql"
        }
      } # Case $::osfamily

    } # mysql
    'pgsql': {
      case $::osfamily {
        'Debian': {
          ensure_packages(['libpq-dev'])
        }
        'RedHat': {
          ensure_packages(['postgresql-devel'])
        }
        default: {
          err "${::osfamily} not supported yet for pgsql"
        }
      } # Case $::osfamily

    } # pgsql
    default: {
      err "${gitlab_dbtype} not supported yet"
    }
  } # Case $::gitlab_dbtype

  # other packages
  ensure_packages([$git_package_name,'postfix','curl'])

  # dev. dependencies
  ensure_packages($system_packages)

  case $::operatingsystem {
    'ubuntu': {
      class { 'ruby':
        ruby_package     => 'ruby1.9.3',
        rubygems_package => 'rubygems1.9.1',
        rubygems_update  => false,
      }
      Package <| name == 'ruby1.9.3' |> {
        notify +> [ Exec['ruby-version'], Exec['gem-version'] ],
      }
      exec { 'ruby-version':
        command     => '/usr/bin/update-alternatives --set ruby /usr/bin/ruby1.9.1',
        user        => root,
        refreshonly => true,
        before      => Class['Ruby::Dev'],
      }
      exec { 'gem-version':
        command     => '/usr/bin/update-alternatives --set gem /usr/bin/gem1.9.1',
        user        => root,
        refreshonly => true,
        before      => Class['Ruby::Dev'],
      }
    }
    default: {
      class { 'ruby':
        version         => '1:1.9.3',
        rubygems_update => false;
      }
    }
  }

  class { 'ruby::dev': }

} # Class:: gitlab::dependency inherits gitlab
