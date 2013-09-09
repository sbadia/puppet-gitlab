# Class:: gitlab::service
#
#
class gitlab::service inherits gitlab {
  service { 'gitlab':
    ensure     => running,
    hasstatus  => true,
    hasrestart => true,
    enable     => true,
  }
}
