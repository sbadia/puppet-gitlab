# == define: gitlab::config::resque
#
# [*group*]
#   (required) group for gitlab database configuration file.
#
# [*owner*]
#   (required) owner for gitlab database configuration file.
#
# [*path*]
#   (required) path for gitlab database configuration file.
#
# [*redis_host*]
#   (required) Redis host used for Sidekiq
#
# [*redis_port*]
#   (required) Redis host used for Sidekiq
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
