# Class:: gitlab::gitolite inherits gitlab::pre
#
#
class gitlab::gitolite inherits gitlab::pre {
  file {
    "/var/cache/debconf/gitolite.preseed":
      content => template('gitlab/gitolite.preseed.erb'),
      ensure  => file,
      before  => Package["gitolite"];
    "${git_home}/${git_user}.pub":
      content => $git_admin_pubkey,
      ensure  => file,
      owner   => $git_user,
      group   => $git_user,
      mode    => 644,
      require => User["${git_user}"];
    "${git_home}/.gitolite.rc":
      source  => "puppet:///modules/gitlab/gitolite-rc",
      ensure  => file,
      owner   => $git_user,
      group   => $git_user,
      mode    => 644,
      require => [Package["gitolite"],User["${git_user}"]];
    "${git_home}/.gitolite/hooks/common/post-receive":
      source  => "puppet:///modules/gitlab/post-receive",
      ensure  => file,
      owner   => $git_user,
      group   => $git_user,
      mode    => 755,
      require => [Exec["gl-setup gitolite"],User["${git_user}"]];
    "${git_home}/.gitconfig":
      content => template('gitlab/gitolite.gitconfig.erb'),
      ensure  => file,
      owner   => $git_user,
      group   => $git_user,
      mode    => 644,
      require => Package["gitolite"];
    "${git_home}/.profile":
      ensure => file,
      source => "puppet:///modules/gitlab/git_user-dot-profile",
      owner  => $git_user,
      group  => $git_user,
      mode   => 644;
  }

  package {
    "gitolite":
      ensure       => installed,
      notify       => Exec["gl-setup gitolite"],
      responsefile => "/var/cache/debconf/gitolite.preseed";
  }

  exec {
    "gl-setup gitolite":
      command     => "/bin/su -c '/usr/bin/gl-setup ${git_home}/${git_user}.pub > /dev/null 2>&1' ${git_user}",
      user        => root,
      require     => [Package["gitolite"],File["${git_home}/.gitconfig"],File["${git_home}/${git_user}.pub"]],
      refreshonly => "true";
  }

  file { "${git_home}/repositories":
    ensure    => directory,
    owner     => $git_user,
    group     => $git_user,
    mode      => 0770,
    subscribe => Exec['gl-setup gitolite']
  }

  # Solve strange issue with gitolite on ubuntu (https://github.com/sbadia/puppet-gitlab/issues/9)
  # So create a VERSION file if it doesn't exist
  if $operatingsystem == 'Ubuntu' {
    file {
      "/etc/gitolite":
        ensure  => directory,
        mode    => 0755;
      "/etc/gitolite/VERSION":
        content => "42",
        ensure  => file,
        replace => false,
        owner   => root,
        group   => root,
        mode    => 0644,
        require => File["/etc/gitolite"];
    }
  }
} # Class:: gitlab::gitolite inherits gitlab::pre
