# Class:: gitlab::gitolite
class gitlab::gitolite {
  include gitlab
  require gitlab::pre

  $git_user         = $gitlab::git_user
  $git_home         = $gitlab::git_home
  $git_admin_pubkey = $gitlab::git_admin_pubkey
  $git_email        = $gitlab::git_email

  case $gitlab::ssh_key_provider {
    content: {
      File["${git_home}/${gitlab::git_user}.pub"] {
        content => $gitlab::git_admin_pubkey }
    }
    source: {
      File["${git_home}/${gitlab::git_user}.pub"] {
        source => $gitlab::git_admin_pubkey }
    }
    default: {
      err "${gitlab::ssh_key_provider} not supported yet"
    }
  } # case ssh

  File {owner => $git_user, group => $git_user, }
  file {
    "${git_home}/${git_user}.pub":
      mode    => '0644';
    "${git_home}/.gitolite/hooks/common/post-receive":
      source  => 'puppet:///modules/gitlab/post-receive',
      mode    => '0755',
      require => Exec['gitolite setup'];
    "${git_home}/.gitconfig":
      content => template('gitlab/gitolite.gitconfig.erb'),
      mode    => '0644';
    "${git_home}/.profile":
      source => 'puppet:///modules/gitlab/git_user-dot-profile',
      mode   => '0644';
    "${git_home}/repositories":
      ensure    => directory,
      mode      => '0770';
  }

  case $::osfamily {
    Debian: {
        $glsetup_cmd = "/bin/su -c '/usr/bin/gl-setup ${git_home}/${git_user}.pub > /dev/null 2>&1' ${git_user}"
        file { "${git_home}/.gitolite.rc":
               source  => 'puppet:///modules/gitlab/gitolite-rc',
               mode    => '0644',
               before  => Exec['gitolite setup']
        }
    } #Debian
    Redhat: {
      file {
        "${git_home}/.gitolite": ensure => directory, mode => '0750';
        "${git_home}/.gitolite/logs": ensure => directory, mode => '0750', require => File["${git_home}/.gitolite"], before => Exec['gitolite setup'],
      }
      $glsetup_cmd = "/usr/bin/gitolite setup -pk ${git_home}/${git_user}.pub"
    } # Redhat
  }

  exec { 'gitolite setup':
    command     => $glsetup_cmd,
    user        => $git_user,
    environment => ["HOME=${git_home}"],
    require     => [File["${git_home}/.gitconfig"],File["${git_home}/${git_user}.pub"]],
    logoutput   => 'on_failure',
    creates     => "${git_home}/projects.list";
  }

  # Solve strange issue with gitolite on ubuntu (https://github.com/sbadia/puppet-gitlab/issues/9)
  # So create a VERSION file if it doesn't exist
  if $::osfamily == 'Debian' {
    file {
      '/etc/gitolite':
        ensure  => directory,
        mode    => '0755';
      '/etc/gitolite/VERSION':
        ensure  => file,
        content => '42',
        replace => false,
        owner   => root,
        group   => root,
        mode    => '0644',
        require => File['/etc/gitolite'];
    }
  }
} # Class:: gitlab::gitolite inherits gitlab::pre
