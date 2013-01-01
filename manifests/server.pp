# Class:: gitlab::server
class gitlab::server {
  include gitlab
  require gitlab::gitolite
  require gitlab::nginx

  $gitlab_dbtype  = $gitlab::gitlab_dbtype
  $gitlab_dbname  = $gitlab::gitlab_dbname
  $gitlab_dbuser  = $gitlab::gitlab_dbuser
  $gitlab_dbpwd   = $gitlab::gitlab_dbpwd
  $gitlab_home    = $gitlab::gitlab_home
  $gitlab_user    = $gitlab::gitlab_user
  $git_home       = $gitlab::git_home
  $git_email      = $gitlab::git_email

  package {
    'bundler':
      ensure   => installed,
      provider => gem;
    'charlock_holmes':
      ensure   => '0.6.9',
      provider => gem;
    'pygments':
      ensure   => installed,
      provider => pip;
  }

  case $gitlab_dbtype {
    mysql: {
      $gitlab_without_gems = 'postgres'
    }
    postgres: {
      $gitlab_without_gems = 'mysql'
    }
    default: {
      # Install all db type gems
      $gitlab_without_gems = ''
    }
  }

  exec {
    'Get gitlab':
      command     => "git clone -b ${gitlab::gitlab_branch} ${gitlab::gitlab_sources} ./gitlab",
      creates     => "${gitlab_home}/gitlab",
      logoutput   => 'on_failure',
      cwd         => $gitlab_home,
      path        => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
      user        => $gitlab_user,
      unless      => "/usr/bin/test -d ${gitlab_home}/gitlab";
    'Install gitlab':
      command     => "bundle install --without development test ${gitlab_without_gems} --deployment",
      logoutput   => 'on_failure',
      provider    => shell,
      cwd         => "${gitlab_home}/gitlab",
      path        => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
      user        => $gitlab_user,
      require     => [Exec['Get gitlab'], Package['bundler']];
    'Setup gitlab DB':
      command     => 'bundle exec rake gitlab:app:setup RAILS_ENV=production; bundle exec rake gitlab:app:enable_automerge RAILS_ENV=production; bundle exec rake db:migrate RAILS_ENV=production',
      logoutput   => 'on_failure',
      provider    => shell,
      cwd         => "${gitlab_home}/gitlab",
      path        => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
      user        => $gitlab_user,
      require     => [
        Exec['Install gitlab'],
        File["${gitlab_home}/gitlab/config/database.yml"],
        File["${gitlab_home}/gitlab/tmp"],
        Sshkey['localhost'],
        File["${gitlab_home}/.ssh/id_rsa"],
        Package['bundler']
        ],
      refreshonly => true;
  }


  # fixing eventmachine and thin gem build problems on newer debian/ubuntu versions
  if ($::osfamily == 'Debian'){
    file {
      "${gitlab_home}/gitlab/.bundle":
        ensure  => directory,
        owner   => $gitlab_user,
        group   => $gitlab_user,
        require => Exec['Get gitlab'],
        before  => File['bundle_config'];
      'bundle_config':
        path    => "${gitlab_home}/gitlab/.bundle/config",
        content => template('gitlab/gitlab.bundle.config.erb'),
        owner   => $gitlab_user,
        group   => $gitlab_user,
        before  => Exec['Install gitlab']; }
  }

  file {
    "${gitlab_home}/gitlab/config/database.yml":
      ensure  => file,
      content => template('gitlab/database.yml.erb'),
      owner   => $gitlab_user,
      group   => $gitlab_user,
      require => [Exec['Get gitlab'],File["${gitlab_home}/gitlab/config/gitlab.yml"]];
    "${gitlab_home}/gitlab/config/unicorn.rb":
      ensure  => file,
      content => template('gitlab/unicorn.rb.erb'),
      owner   => $gitlab_user,
      group   => $gitlab_user,
      require => [Exec['Get gitlab'],File["${gitlab_home}/gitlab/config/gitlab.yml"]];
    "${gitlab_home}/gitlab/config/gitlab.yml":
      ensure  => file,
      content => template('gitlab/gitlab.yml.erb'),
      owner   => $gitlab_user,
      group   => $gitlab_user,
      mode    => '0640',
      require => Exec['Get gitlab'],
      notify  => Exec['Setup gitlab DB'];
    "${gitlab_home}/gitlab/tmp":
      ensure  => directory,
      owner   => $gitlab_user,
      group   => $gitlab_user,
      require => Exec['Get gitlab'];
    "${gitlab_home}/.gitconfig":
      content => template('gitlab/gitolite.gitconfig.erb'),
      mode    => '0644';
  }

  sshkey {
    'localhost':
      ensure       => present,
      host_aliases => $::fqdn,
      key          => $::sshrsakey,
      type         => 'ssh-rsa'
  }

  case $::osfamily {
    Redhat: { $nginx_group = 'nginx' }
    Debian: { $nginx_group = 'www-data' }
  }

  file { # SSH keys
    "${gitlab_home}/.ssh":
      ensure => directory,
      owner  => $gitlab_user,
      group  => $gitlab_user,
      mode   => '0700';
    "/var/lib/gitlab":
      ensure => directory,
      owner  => $gitlab_user,
      group  => $nginx_group,
      mode   => '0775';
    "${gitlab_home}/.ssh/id_rsa":
      ensure  => file,
      owner   => $gitlab_user,
      group   => $gitlab_user,
      mode    => '0600';
    "${gitlab_home}/.ssh/id_rsa.pub":
      ensure  => file,
      owner   => $gitlab_user,
      group   => $gitlab_user,
      mode    => '0644';
    '/etc/ssh/ssh_known_hosts':
      ensure  => file,
      owner   => root,
      group   => root,
      mode    => '0644',
      require => Sshkey['localhost']
  }

  case $gitlab::ssh_key_provider {
    content: {
      File["${gitlab_home}/.ssh/id_rsa"] { content => $gitlab::git_admin_privkey }
      File["${gitlab_home}/.ssh/id_rsa.pub"] { content => $gitlab::git_admin_pubkey }
    }
    source: {
      File["${gitlab_home}/.ssh/id_rsa"] { source => $gitlab::git_admin_privkey }
      File["${gitlab_home}/.ssh/id_rsa.pub"] { source => $gitlab::git_admin_pubkey }
    }
    default: {
      err "${gitlab::ssh_key_provider} not supported yet"
    }
  } # case ssh

  file {
    '/etc/init.d/gitlab':
      ensure  => file,
      content => template('gitlab/gitlab.init.erb'),
      owner   => root,
      group   => root,
      mode    => '0755',
      notify  => Service['gitlab'],
      require => Exec['Setup gitlab DB'];
  }

  service {
    'gitlab':
      ensure    => running,
      require   => File['/etc/init.d/gitlab'],
      hasstatus => false,
      pattern   => 'unicorn_rails',
      enable    => true;
  }
} # Class:: gitlab::server
