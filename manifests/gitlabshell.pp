# Class:: gitlab::gitlabshell
#
#
class gitlab::gitlabshell {
  include gitlab
  require gitlab::pre

  $git_user         = $gitlab::git_user
  $git_home         = $gitlab::git_home

  file {
    "${git_home}/gitlab-shell/config.yml":
      ensure  => file,
      content => template('gitlab/gitlab-shell.config.yml.erb'),
      owner   => $git_user,
      group   => $git_user,
      mode    => '0644',
      notify  => Exec['Setup gitlab-shell'],
      require => Exec['Get gitlab-shell'];
  }

  exec {
    'Get gitlab-shell':
      command   => "git clone -b ${gitlab::gitlabshell_branch} ${gitlab::gitlabshell_sources} ${git_home}/gitlab-shell",
      path      => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
      logoutput => 'on_failure',
      user      => $git_user,
      cwd       => $git_home,
      require   => User[$git_user],
      unless    => "/usr/bin/test -d ${git_home}/gitlab-shell";
    'Setup gitlab-shell':
      command   => "ruby ${git_home}/gitlab-shell/bin/install",
      path      => '/bin:/usr/sbin:/usr/bin:/sbin:/bin',
      user      => $git_user,
      cwd       => $git_home,
      require   => File["${git_home}/gitlab-shell/config.yml"],
      logoutput => 'on_failure',
      creates   => "${git_home}/repositories";
  }
} # Class:: gitlab::gitolite
