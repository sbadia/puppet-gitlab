# Class:: gitlab::gitolite
#
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
      mode    => '0644',
      before  => Exec['Setup gitolite'];
    "${git_home}/.gitolite/hooks/common/post-receive":
      source  => 'puppet:///modules/gitlab/post-receive',
      mode    => '0755',
      require => Exec['Setup gitolite'];
    "${git_home}/.gitconfig":
      content => template('gitlab/gitolite.gitconfig.erb'),
      mode    => '0644';
    "${git_home}/.profile":
      source  => 'puppet:///modules/gitlab/git_user-dot-profile',
      mode    => '0644';
    "${git_home}/repositories":
      ensure  => directory,
      require => Exec['Setup gitolite'],
      mode    => '0770';
    "${git_home}/bin":
      ensure  => directory;
  }

  case $::osfamily {
    Redhat: {
      file {
        "${git_home}/.gitolite":
          ensure  => directory,
          mode    => '0750';
        "${git_home}/.gitolite/logs":
          ensure  => directory,
          mode    => '0750',
          require => File["${git_home}/.gitolite"],
          before  => Exec['Setup gitolite'];
      }
    } # Redhat
  } # Case

  exec {
    'Get patched gitolite':
      command   => "git clone -b ${gitlab::gitolite_branch} ${gitlab::gitolite_sources} ${git_home}/gitolite",
      path      => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
      logoutput => 'on_failure',
      user      => $git_user,
      require   => User[$git_user],
      unless    => "/usr/bin/test -d ${git_home}/gitolite";
    'Install patched gitolite':
      command     => "${git_home}/gitolite/install -ln ${git_home}/bin",
      user        => $git_user,
      require     => [Exec['Get patched gitolite'],File["${git_home}/bin"]],
      unless    => "/usr/bin/test -f ${git_home}/bin/gitolite";
    'Setup gitolite':
      command     => "sudo -u ${git_user} -H sh -c \"PATH=${git_home}/bin:/usr/sbin:/usr/bin:/sbin:/bin; gitolite setup -pk ${git_home}/${git_user}.pub\"",
      path        => "/bin:/usr/sbin:/usr/bin:/sbin:/bin",
      user        => root,
      require     => [File["${git_home}/.gitconfig"],File["${git_home}/${git_user}.pub"]],
      logoutput   => 'on_failure',
      creates     => "${git_home}/projects.list";
  }
} # Class:: gitlab::gitolite
