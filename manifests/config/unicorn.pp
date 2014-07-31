#
define gitlab::config::unicorn (
  $group,
  $home,
  $http_timeout,
  $owner,
  $path,
  $relative_url_root,
  $unicorn_port,
  $unicorn_worker
){

  file { $path:
    ensure  => file,
    content => template('gitlab/unicorn.rb.erb'),
    owner   => $owner,
    group   => $group,
  }

}
