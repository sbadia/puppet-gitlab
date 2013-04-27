# Module:: gitlab::apt
# Manifest:: apt.pp
#
# Author:: Sebastien Badia (<seb@sebian.fr>)
# Date:: 2013-04-27 12:41:12 +0200
# Maintainer:: Sebastien Badia (<seb@sebian.fr>)
#
# This class is used by vagrant (with puppet stage)

# Class:: gitlab::apt
#
#
class gitlab::apt {

  exec {
    'apt-get update':
      command   => '/usr/bin/apt-get update',
      user      => root,
      logoutput => 'on_failure';
  }

} # Class:: gitlab::apt
