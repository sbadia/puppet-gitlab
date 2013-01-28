# Class:: gitlab::server
#
#
class gitlab::server {
  include gitlab
  require gitlab::gitolite
  require gitlab::nginx

  $gitlab_dbtype      = $gitlab::gitlab_dbtype
  $gitlab_dbname      = $gitlab::gitlab_dbname
  $gitlab_dbuser      = $gitlab::gitlab_dbuser
  $gitlab_dbpwd       = $gitlab::gitlab_dbpwd
  $gitlab_dbhost      = $gitlab::gitlab_dbhost
  $gitlab_dbport      = $gitlab::gitlab_dbport
  $gitlab_domain      = $gitlab::gitlab_domain
  $gitlab_home        = $gitlab::gitlab_home
  $gitlab_user        = $gitlab::gitlab_user
  $gitlab_branch      = $gitlab::gitlab_branch
  $gitlab_sources     = $gitlab::gitlab_sources
  $git_home           = $gitlab::git_home
  $git_user           = $gitlab::git_user
  $git_email          = $gitlab::git_email
  $ldap_enabled       = $gitlab::ldap_enabled
  $ldap_host          = $gitlab::ldap_host
  $ldap_base          = $gitlab::ldap_base
  $ldap_uid           = $gitlab::ldap_uid
  $ldap_port          = $gitlab::ldap_port
  $ldap_method        = $gitlab::ldap_method
  $ldap_bind_dn       = $gitlab::ldap_bind_dn
  $ldap_bind_password = $gitlab::ldap_bind_password


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

  $gitlab_without_gems = $gitlab_dbtype ? {
    mysql    => 'postgres',
    pgsql    => 'mysql',
    default  => '',
  }

  Exec{
    path => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
    logoutput   => 'on_failure',
  }

  exec {
    'Get gitlab':
      command     => "git clone -b ${gitlab_branch} ${gitlab_sources} ./gitlab",
      creates     => "${gitlab_home}/gitlab",
      cwd         => $gitlab_home,
      user        => $gitlab_user,
      unless      => "/usr/bin/test -d ${gitlab_home}/gitlab";
    'Install gitlab':
      command     => "bundle install --without development test ${gitlab_without_gems} --deployment",
      provider    => 'shell',
      cwd         => "${gitlab_home}/gitlab",
      user        => $gitlab_user,
      require     => [
        Exec['Get gitlab'],
        Package['bundler']
      ];
    'Setup gitlab DB':
      # /usr/bin/yes \"yes\" | bundle exec rake gitlab:setup RAILS_ENV=production
      command     => 'bundle exec rake gitlab:setup RAILS_ENV=production',
      provider    => 'shell',
      cwd         => "${gitlab_home}/gitlab",
      user        => $gitlab_user,
      creates     => "${gitlab_home}/.gitlab_setup_done",
      require     => [
        Exec['Install gitlab'],
        File["${gitlab_home}/gitlab/config/database.yml"],
        File["${gitlab_home}/gitlab/tmp"],
        Sshkey['localhost'],
        File["${gitlab_home}/.ssh/id_rsa"],
        Package['bundler']
        ],
      refreshonly => true;
    # Note: removed in e65417a
    # bundle exec rake gitlab:app:enable_automerge RAILS_ENV=production
    'Migrate gitlab DB':
      command   => 'bundle exec rake db:migrate RAILS_ENV=production',
      provider  => 'shell',
      cwd       => "${gitlab_home}/gitlab",
      user      => $gitlab_user,
      require   => [
        Exec['Install gitlab'],
        Exec['Checkout correct gitlab branch'],
        File["${gitlab_home}/gitlab/config/database.yml"],
        File["${gitlab_home}/gitlab/tmp"],
        Sshkey['localhost'],
        File["${gitlab_home}/.ssh/id_rsa"],
        Package['bundler']
        ];
    'Copy post-receive hook':
      command   => "cp ${gitlab_home}/gitlab/lib/hooks/post-receive ${git_user}/.gitolite/hooks/common/post-receive",
      user      => $git_user,
      provider  => 'shell',
      require   => Exec['Migrate gitlab DB'];
    'Setup git for git user':
      command   => "su -l -c 'git config --global user.name GitLab' ${gitlab_user} ; su -l -c 'git config --global user.email ${git_email}' ${gitlab_user}",
      provider  => 'shell',
      require   => Exec['Migrate gitlab DB'];
  }

  file {
    '/.gitlab_setup_done':
      ensure  => 'present',
      owner   => 'root',
      group   => 'root',
      require => Exec['Migrate gitlab DB'];
  }


  # fixing eventmachine and thin gem build problems
  # on newer debian/ubuntu versions
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
      require => [Exec['Get gitlab'],
                  File["${gitlab_home}/gitlab/config/gitlab.yml"]];
    "${gitlab_home}/gitlab/config/unicorn.rb":
      ensure  => file,
      content => template('gitlab/unicorn.rb.erb'),
      owner   => $gitlab_user,
      group   => $gitlab_user,
      require => [Exec['Get gitlab'],
                  File["${gitlab_home}/gitlab/config/gitlab.yml"]];
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
    Redhat:   { $nginx_group = 'nginx' }
    Debian:   { $nginx_group = 'www-data' }
    default:  { warning "${::osfamily} not supported yet" }
  }

  file { # SSH keys
    "${gitlab_home}/.ssh":
      ensure => directory,
      owner  => $gitlab_user,
      group  => $gitlab_user,
      mode   => '0700';
    '/var/lib/gitlab':
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
      File["${gitlab_home}/.ssh/id_rsa"] {
        content => $gitlab::git_admin_privkey
      }
      File["${gitlab_home}/.ssh/id_rsa.pub"] {
        content => $gitlab::git_admin_pubkey
      }
    }
    source: {
      File["${gitlab_home}/.ssh/id_rsa"] {
        source => $gitlab::git_admin_privkey
      }
      File["${gitlab_home}/.ssh/id_rsa.pub"] {
        source => $gitlab::git_admin_pubkey
      }
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
