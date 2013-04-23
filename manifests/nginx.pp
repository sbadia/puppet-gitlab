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
    '/etc/nginx/sites-available/gitlab':
      ensure  => file,
      content => template('gitlab/nginx-gitlab.conf.erb'),
      owner   => root,
      group   => root,
      mode    => '0644',
      require => Package['nginx'];
    '/etc/nginx/sites-enabled/gitlab':
      ensure  => link,
      target  => '/etc/nginx/sites-available/gitlab',
      require => File['/etc/nginx/sites-available/gitlab'],
      notify  => Service['nginx'];
  }

  service {
    'nginx':
      ensure  => running,
      require => Package['nginx'],
      enable  => true;
  }
} # Class:: gitlab::nginx
