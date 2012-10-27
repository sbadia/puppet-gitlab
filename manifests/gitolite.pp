# Class:: gitlab::gitolite inherits gitlab::pre
#
#
class gitlab::gitolite inherits gitlab::pre {
  file {
    '/var/cache/debconf/gitolite.preseed':
      ensure  => file,
      content => template('gitlab/gitolite.preseed.erb'),
      before  => Package['gitolite'];
    "${git_home}/${git_user}.pub":
      ensure  => file,
      owner   => $git_user,
      group   => $git_user,
      mode    => '0644',
      require => User[$git_user];
    "${git_home}/.gitolite.rc":
      ensure  => file,
      source  => 'puppet:///modules/gitlab/gitolite-rc',
      owner   => $git_user,
      group   => $git_user,
      mode    => '0644',
      require => [Package['gitolite'],User[$git_user]];
    "${git_home}/.gitolite/hooks/common/post-receive":
      ensure  => file,
      source  => 'puppet:///modules/gitlab/post-receive',
      owner   => $git_user,
      group   => $git_user,
      mode    => '0755',
      require => Package['gitolite'];
    "${git_home}/.gitolite":
      ensure  => directory,
      mode    => '0755',
      require => Package['gitolite'];
    "${git_home}/.gitconfig":
      ensure  => file,
      content => template('gitlab/gitolite.gitconfig.erb'),
      owner   => $git_user,
      group   => $git_user,
      mode    => '0644',
      require => Package['gitolite'];
    "${git_home}/.profile":
      ensure => file,
      source => 'puppet:///modules/gitlab/git_user-dot-profile',
      owner  => $git_user,
      group  => $git_user,
      mode   => '0644';
  }

  package {
    'gitolite':
      ensure       => installed,
      responsefile => '/var/cache/debconf/gitolite.preseed';
  }

  exec {
    'gl-setup gitolite':
      command     => "/bin/su -c '/usr/bin/gl-setup ${git_home}/${git_user}.pub > /dev/null 2>&1' ${git_user}",
      user        => $git_user,
      require     => [Package['gitolite'],File["${git_home}/.gitconfig"],File["${git_home}/${git_user}.pub"]],
      logoutput   => 'on_failure',
      unless      => "/usr/bin/test -f ${git_home}/projects.list";
  }

  file {
    "${git_home}/repositories":
      ensure    => directory,
      owner     => $git_user,
      group     => $git_user,
      mode      => '0770',
      require   => Package['gitolite'];
  }

  # Solve strange issue with gitolite on ubuntu (https://github.com/sbadia/puppet-gitlab/issues/9)
  # So create a VERSION file if it doesn't exist
  if $operatingsystem == 'Ubuntu' {
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
