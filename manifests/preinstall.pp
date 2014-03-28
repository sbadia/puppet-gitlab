# Class:: gitlab::preinstall inherits gitlab
#
#
class gitlab::preinstall inherits gitlab {

  include redis
  include nginx

  # database dependencies
  case $gitlab_dbtype {
    'mysql': {

      class { 'mysql::server': }

      mysql::db {
        $gitlab_dbname:
          user     => $gitlab_dbuser,
          password => $gitlab_dbpwd,
      }

    } # mysql
    'pgsql': {

      class { 'postgresql::server': }

      postgresql::server::db { $gitlab_dbname:
        user     => $gitlab_dbuser,
        password => postgresql_password($gitlab_dbuser, $gitlab_dbpwd),
      }

    } # pgsql
    default: {
      err "${gitlab_dbtype} not supported yet"
    }
  } # Case $::gitlab_dbtype

} # Class:: gitlab::dependency inherits gitlab
