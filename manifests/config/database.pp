# == define: gitlab::config::database
#
# [*database*]
#   (required) Gitlab database name.
#
# [*owner*]
#   (required) owner for gitlab database configuration file.
#
# [*host*]
#   (required) Gitlab database host.
#
# [*group*]
#   (required) group for gitlab database configuration file.
#
# [*password*]
#   (required) Gitlab database password.
#
# [*path*]
#   (required) path for gitlab database configuration file.
#
# [*port*]
#   (required) Gitlab database port.
#
# [*type*]
#   (required) Gitlab database type (pgsql or mysql).
#
# [*username*]
#   (required) Gitlab database username.
#
define gitlab::config::database(
  $database,
  $group,
  $host,
  $owner,
  $password,
  $path,
  $port,
  $type,
  $username,
){

  file { $path:
    ensure  => file,
    content => template('gitlab/database.yml.erb'),
    mode    => '0640',
    owner   => $owner,
    group   => $group,
  }
}
