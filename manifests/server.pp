# Class:: gitlab::server
#
#
class gitlab::server {
  include gitlab
  require gitlab::gitlabshell
  require gitlab::nginx

  $gitlab_dbtype      = $gitlab::gitlab_dbtype
  $gitlab_dbname      = $gitlab::gitlab_dbname
  $gitlab_dbuser      = $gitlab::gitlab_dbuser
  $gitlab_dbpwd       = $gitlab::gitlab_dbpwd
  $gitlab_dbhost      = $gitlab::gitlab_dbhost
  $gitlab_dbport      = $gitlab::gitlab_dbport
  $gitlab_domain      = $gitlab::gitlab_domain
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
      creates     => "${git_home}/gitlab",
      cwd         => $git_home,
      user        => $git_user,
    'Install gitlab':
      command     => "bundle install --without development test ${gitlab_without_gems} --deployment",
      provider    => 'shell',
      cwd         => "${git_home}/gitlab",
      user        => $git_user,
      require     => [
        Exec['Get gitlab'],
        Package['bundler']
      ];
    # FIXME sudo ln -s /usr/bin/python /usr/bin/python2
    # recommanded by gitlab (bundle exec rake gitlab:check RAILS_ENV=production)
    # but it's a bit ugly...
    'Setup gitlab DB':
      command     => '/usr/bin/yes yes | bundle exec rake gitlab:setup RAILS_ENV=production',
      provider    => 'shell',
      cwd         => "${git_home}/gitlab",
      user        => $git_user,
      creates     => "${git_home}/.gitlab_setup_done",
      require     => [
        Exec['Install gitlab'],
        File["${git_home}/gitlab/config/database.yml"],
        File["${git_home}/gitlab/tmp"],
        Sshkey['localhost'],
        Package['bundler']
        ],
      refreshonly => true;
  }

  file {
    "${git_home}/.gitlab_setup_done":
      ensure  => 'present',
      owner   => 'root',
      group   => 'root',
      require => Exec['Setup gitlab DB'];
  }


  # fixing eventmachine and thin gem build problems
  # on newer debian/ubuntu versions
  if ($::osfamily == 'Debian'){
    file {
      "${git_home}/gitlab/.bundle":
        ensure  => directory,
        owner   => $git_user,
        group   => $git_user,
        require => Exec['Get gitlab'],
        before  => File['bundle_config'];
      'bundle_config':
        path    => "${git_home}/gitlab/.bundle/config",
        content => template('gitlab/gitlab.bundle.config.erb'),
        owner   => $git_user,
        group   => $git_user,
        before  => Exec['Install gitlab']; }
  }

  file {
    "${git_home}/gitlab/config/database.yml":
      ensure  => file,
      content => template('gitlab/database.yml.erb'),
      owner   => $git_user,
      group   => $git_user,
      require => [Exec['Get gitlab'],
                  File["${git_home}/gitlab/config/gitlab.yml"]];
    "${git_home}/gitlab/config/unicorn.rb":
      ensure  => file,
      content => template('gitlab/unicorn.rb.erb'),
      owner   => $git_user,
      group   => $git_user,
      require => [Exec['Get gitlab'],
                  File["${git_home}/gitlab/config/gitlab.yml"]];
    "${git_home}/gitlab/config/gitlab.yml":
      ensure  => file,
      content => template('gitlab/gitlab.yml.erb'),
      owner   => $git_user,
      group   => $git_user,
      mode    => '0640',
      require => Exec['Get gitlab'],
      notify  => Exec['Setup gitlab DB'];
    "${git_home}/gitlab/tmp":
      ensure  => directory,
      owner   => $git_user,
      group   => $git_user,
      require => Exec['Get gitlab'];
    "${git_home}/.gitconfig":
      content => template('gitlab/git.gitconfig.erb'),
      mode    => '0644';
    "${git_home}/gitlab-satellites":
      ensure  => directory;
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

  file {
    '/var/lib/gitlab':
      ensure => directory,
      owner  => $git_user,
      group  => $nginx_group,
      mode   => '0775';
  }

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
      hasstatus => true,
      enable    => true;
  }
} # Class:: gitlab::server
