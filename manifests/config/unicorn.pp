# == define: gitlab::config::unicorn
#
# [*owner*]
#   (required) owner for gitlab database configuration file.
#
# [*group*]
#   (required) group for gitlab database configuration file.
#
# [*home*]
#   (required) Home directory for gitlab repository
#
# [*http_timeout*]
#   (required) HTTP timeout (unicorn and nginx)
#
# [*path*]
#   (required) path for gitlab database configuration file.
#
# [*unicorn_listen*]
#   (required) IP address that unicorn listens on
#
# [*unicorn_port*]
#   (required) Port that unicorn listens on 172.0.0.1 for HTTP traffic
#
# [*unicorn_worker*]
#   (required) The number of unicorn worker
#
# [*relative_url_root*]
#   (required) run in a non-root path
#
define gitlab::config::unicorn (
  $group,
  $home,
  $http_timeout,
  $owner,
  $path,
  $unicorn_listen,
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
