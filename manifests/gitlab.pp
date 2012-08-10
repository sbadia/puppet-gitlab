# Class:: gitlab::gitlab inherits gitlab::gitolite
#
#
class gitlab::gitlab inherits gitlab::gitolite {
  package {
    "bundler":
      ensure   => installed,
      provider => gem;
    "pygments":
      ensure  => installed,
      provider => pip;
  }

  exec {
    "Get gitlab":
      command   => "git clone -b ${gitlab_branch} ${gitlab_sources} ./gitlab",
      creates   => "${gitlab_home}/gitlab",
      logoutput => true,
      cwd       => $gitlab_home,
      path      => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
      user      => $gitlab_user,
      unless    => "/usr/bin/test -d ${gitlab_home}/gitlab",
      require   => Package["gitolite"];
    "Install gitlab":
      command   => "bundle install --without development test --deployment",
      logoutput => true,
      cwd       => "${gitlab_home}/gitlab",
      path      => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
      user      => $gitlab_user,
      require   => [Exec["Get gitlab"],Package['gitolite'],Package['bundler']];
    "Setup gitlab DB":
      command     => "bundle exec rake gitlab:app:setup RAILS_ENV=production; bundle exec rake gitlab:app:enable_automerge RAILS_ENV=production",
      logoutput   => true,
      cwd         => "${gitlab_home}/gitlab",
      path        => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
      user        => $gitlab_user,
      require     => [
        Exec["Install gitlab"],
        File["${gitlab_home}/gitlab/config/database.yml"],
        File["${gitlab_home}/gitlab/tmp"],
        Sshkey['localhost'],
        File["${gitlab_home}/.ssh/id_rsa"],
        Package['gitolite'],
        Package['bundler']
        ],
      refreshonly => true;
  }

  if $ldap_enabled == true {
    file { "${gitlab_home}/gitlab/config/initializers/omniauth.rb":
      ensure  => file,
      content => template('gitlab/omniauth.rb.erb'),
      owner   => $gitlab_user,
      group   => $gitlab_user,
      mode    => 0640,
      require => [Exec["Get gitlab"],File["${gitlab_home}/gitlab/config/gitlab.yml"]],
      notify  => Service["gitlab"]
    }
  }

  sshkey { 'localhost':
    ensure       => present,
    host_aliases => $::fqdn,
    key          => $::sshrsakey,
    type         => 'ssh-rsa'
  }

  file { '/etc/ssh/ssh_known_hosts':
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => 0644,
    require => Sshkey['localhost']
  }

  file {
    "${gitlab_home}/gitlab/config/database.yml":
      ensure  => link,
      target  => "${gitlab_home}/gitlab/config/database.yml.${gitlab_dbtype}",
      owner   => $gitlab_user,
      group   => $gitlab_user,
      require => [Exec["Get gitlab"],File["${gitlab_home}/gitlab/config/gitlab.yml"]];
    "${gitlab_home}/gitlab/config/unicorn.rb":
      ensure  => file,
      content => template('gitlab/unicorn.rb.erb'),
      owner   => $gitlab_user,
      group   => $gitlab_user,
      require => [Exec["Get gitlab"],File["${gitlab_home}/gitlab/config/gitlab.yml"]];
    "${gitlab_home}/gitlab/config/gitlab.yml":
      ensure  => file,
      content => template('gitlab/gitlab.yml.erb'),
      owner   => $gitlab_user,
      group   => $gitlab_user,
      mode    => 0640,
      require => Exec["Get gitlab"],
      notify  => Exec["Setup gitlab DB"];
    "${gitlab_home}/gitlab/tmp":
      ensure  => directory,
      owner   => $gitlab_user,
      group   => $gitlab_user,
      require => Exec["Get gitlab"],
  }

  file { # SSH keys
    "${gitlab_home}/.ssh":
      ensure => directory,
      owner  => $gitlab_user,
      group  => $gitlab_user,
      mode   => 0700;
    "${gitlab_home}/.ssh/id_rsa":
      ensure  => file,
      owner   => $gitlab_user,
      group   => $gitlab_user,
      mode    => 0600;
    "${gitlab_home}/.ssh/id_rsa.pub":
      ensure  => file,
      owner   => $gitlab_user,
      group   => $gitlab_user,
      mode    => 0644;
  }

  case $ssh_key_provider {
    content: {
      File["${gitlab_home}/.ssh/id_rsa"] { content => "${git_admin_privkey}" }
      File["${gitlab_home}/.ssh/id_rsa.pub"] { content => "${git_admin_pubkey}" }
    }
    source: {
      File["${gitlab_home}/.ssh/id_rsa"] { source => "${git_admin_privkey}" }
      File["${gitlab_home}/.ssh/id_rsa.pub"] { source => "${git_admin_pubkey}" }
    }
    default: {
      err "${ssh_key_provider} not supported yet"
    }
  } # case ssh

  package {
    "nginx":
      ensure => latest
  }

  #TODO: vhost managment
  #      or hostname.tld/gitlab/ installation
  file {
    "/etc/nginx/conf.d/gitlab.conf":
      ensure  => file,
      content => template('gitlab/nginx-gitlab.conf.erb'),
      owner   => root,
      group   => root,
      mode    => 0644,
      require => Package["nginx"],
      notify  => Service["nginx"];
  }

  service {
    "nginx":
      ensure  => running,
      require => Package["nginx"],
      enable  => true;
  }

  file {
    "/etc/init.d/gitlab":
      content => template('gitlab/gitlab.init.erb'),
      ensure  => file,
      owner   => root,
      group   => root,
      mode    => 0755,
      notify  => Service["gitlab"],
      require => Exec["Setup gitlab DB"];
  }

  service {
    "gitlab":
      ensure  => running,
      require => File["/etc/init.d/gitlab"],
      enable  => true;
  }
} # Class:: gitlab::gitlab inherits gitlab::gitolite
