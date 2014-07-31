#
define gitlab::config::resque (
  $group,
  $owner,
  $path,
  $redis_host,
  $redis_port,
){

  file { $path:
    ensure  => file,
    content => template('gitlab/resque.yml.erb'),
    owner   => $owner,
    group   => $group,
  }

}
