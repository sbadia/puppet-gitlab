# Class:: gitlab::ci::setup
#
#
class gitlab::ci::setup inherits gitlab::ci {

  include git

  File {
    owner     => $ci_user,
    group     => $ci_user,
  }

  # user
  user { $ci_user:
    ensure   => present,
    shell    => '/bin/bash',
    password => '*',
    home     => $ci_home,
    comment  => $ci_comment,
    system   => true,
  }

  # directories
  file { $ci_home:
    ensure => directory,
    mode   => '0755',
  }

}
