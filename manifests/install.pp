# Class:: gitlab::install
#
#
class gitlab::install inherits gitlab {
  Exec {
    user => $git_user,
    path => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
  }

  File {
    owner => $git_user,
    group => $git_user,
  }

  # gitlab shell
  file { "${git_home}/gitlab-shell/config.yml":
    ensure  => file,
    content => template('gitlab/gitlab-shell.config.yml.erb'),
    mode    => '0644',
  }

  exec { 'install gitlab-shell':
    command => "ruby ${git_home}/gitlab-shell/bin/install",
    cwd     => $git_home,
    creates => "${gitlab_repodir}/repositories",
    require => File["${git_home}/gitlab-shell/config.yml"],
  }

  # gitlab
  file { "${git_home}/gitlab/config/database.yml":
    ensure  => file,
    content => template('gitlab/database.yml.erb'),
  }

  file { "${git_home}/gitlab/config/unicorn.rb":
    ensure  => file,
    content => template('gitlab/unicorn.rb.erb'),
  }

  file { "${git_home}/gitlab/config/gitlab.yml":
    ensure  => file,
    content => template('gitlab/gitlab.yml.erb'),
    mode    => '0640',
  }

  file { "${git_home}/gitlab/config/resque.yml":
    ensure  => file,
    content => template('gitlab/resque.yml.erb'),
  }

  exec { 'install gitlab':
    command => "bundle install --without development aws test ${gitlab_without_gems} --deployment",
    cwd     => "${git_home}/gitlab",
    unless  => "/usr/bin/test -f ${git_home}/.git_setup_done",
    timeout => 0,
    require => [
      File["${git_home}/gitlab/config/database.yml"],
      File["${git_home}/gitlab/config/unicorn.rb"],
      File["${git_home}/gitlab/config/gitlab.yml"],
      File["${git_home}/gitlab/config/resque.yml"],
    ],
  }

  exec { 'setup gitlab database':
    command => '/usr/bin/yes yes | bundle exec rake gitlab:setup RAILS_ENV=production',
    cwd     => "${git_home}/gitlab",
    unless  => "/usr/bin/test -f ${git_home}/.git_setup_done",
    creates => "${git_home}/.gitlab_setup_done",
    require => Exec['install gitlab'],
  }

  file { "${git_home}/.gitlab_setup_done":
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    require => Exec['setup gitlab database'],
  }
}
