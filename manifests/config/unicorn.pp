#
define gitlab::config::unicorn (
  $group,
  $home,
  $http_timeout,
  $owner,
  $path,
  $unicorn_port,
  $unicorn_worker,
  $relative_url_root = false
){

  file { $path:
    ensure  => file,
    content => template('gitlab/unicorn.rb.erb'),
    owner   => $owner,
    group   => $group,
  }

}
