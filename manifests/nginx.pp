# Class:: gitlab::nginx
#
#
class gitlab::nginx {
  include gitlab

  #FIXME Manage nginx with puppetlabs recipes, not re-invent the wheel :-)
  $gitlab_domain = $gitlab::gitlab_domain

  package {
    'nginx':
      ensure => latest
  }

  #TODO: vhost managment or hostname.tld/gitlab/ installation
  file {
    '/etc/nginx/conf.d/gitlab.conf':
      ensure  => file,
      content => template('gitlab/nginx-gitlab.conf.erb'),
      owner   => root,
      group   => root,
      mode    => '0644',
      require => Package['nginx'],
      notify  => Service['nginx'];
  }

  service {
    'nginx':
      ensure  => running,
      require => Package['nginx'],
      enable  => true;
  }
} # Class:: gitlab::nginx
