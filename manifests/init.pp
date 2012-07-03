# Module:: gitlab
# Manifest:: init.pp
#
# Author:: Sebastien Badia (<seb@sebian.fr>)
# Date:: Tue Jul 03 20:06:33 +0200 2012
# Maintainer:: Sebastien Badia (<seb@sebian.fr>)
#

# Class:: gitlab
#
#
class gitlab {
  case $operatingsystem {
    debian,ubuntu: {
      include "gitlab::base"
    }
    default: {
      err "${operatingsystem} not supported yet"
    }
  } # case
} # Class:: gitlab

# Class:: gitlab::base
#
#
class gitlab::base {
  package {
    ["git","git-core","wget","curl","gcc","checkinstall",
     "libxml2-dev","libxslt-dev","sqlite3","libsqlite3-dev",
     "libcurl4-openssl-dev","libreadline-dev","libc6-dev","libssl-dev",
     "libmysql++-dev","make","build-essential","zlib1g-dev","libicu-dev",
     "redis-server","openssh-server","python-dev","python-pip","libyaml-dev",
     "ruby1.9.1","ruby1.9.1-dev"]:
      ensure => installed;
  }
} # Class:: gitlab::base
