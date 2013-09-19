# Class:: gitlab::dependencies
#
#
class gitlab::dependencies inherits gitlab {

  # ensure puppet version meets minimum requirements
  if $::puppetversion <= '3.2.0' {
    fail ("puppet >= 3.2 required for gem provider, you have ${::puppetversion}")
  }
  else {
    debug ("puppet ${::puppetversion} supports gem provider")
  }

  # database dependencies
  package { $gitlab::params::db_packages: }

  # system packages
  package { $gitlab::params::system_packages: } ->
  package { 'bundler':
    ensure    => installed,
    provider  => gem,
  } ->
  package { 'charlock_holmes':
    ensure    => '0.6.9.4',
    provider  => gem,
  }
  # other packages
  # FIXME: defined poor form
  if !defined(Package['git-core']) {
    package { 'git-core': }
  }
  # FIXME: defined poor form
  if !defined(Package['postfix']) {
    package { 'postfix': }
  }
}
