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
