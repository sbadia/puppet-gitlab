# Class:: gitlab::dependencies
#
#
class gitlab::dependencies inherits gitlab {

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
