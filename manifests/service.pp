# Class:: gitlab::service
#
#
class gitlab::service {
  service { 'gitlab':
    ensure     => running,
    hasstatus  => true,
    hasrestart => true,
    enable     => true,
  }
}
