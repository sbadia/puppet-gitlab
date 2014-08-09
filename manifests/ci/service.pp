# Class:: gitlab::ci::service
#
#
class gitlab::ci::service {
  service { 'gitlab_ci':
    ensure     => running,
    hasstatus  => true,
    hasrestart => true,
    enable     => true,
  }
}
