# Class:: gitlab::install
#
#
class gitlab::install {
  Exec {
    user => $gitlab::params::git_user,
    path => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
  }

  File {
    owner => $gitlab::params::git_user,
    group => $gitlab::params::git_user,
  }

  # gitlab shell
  file { "${gitlab::params::git_home}/gitlab-shell/config.yml":
    ensure  => file,
    content => template('gitlab/gitlab-shell.config.yml.erb'),
    mode    => '0644',
  }

  exec { 'install gitlab-shell':
    command => "ruby ${gitlab::params::git_home}/gitlab-shell/bin/install",
    cwd     => $gitlab::params::git_home,
    creates => "${gitlab::params::gitlab_repodir}/repositories",
    require => File["${gitlab::params::git_home}/gitlab-shell/config.yml"],
  }

  # gitlab
  file { "${gitlab::params::git_home}/gitlab/config/database.yml":
    ensure  => file,
    content => template('gitlab/database.yml.erb'),
  }

  file { "${gitlab::params::git_home}/gitlab/config/unicorn.rb":
    ensure  => file,
    content => template('gitlab/unicorn.rb.erb'),
  }

  file { "${gitlab::params::git_home}/gitlab/config/gitlab.yml":
    ensure  => file,
    content => template('gitlab/gitlab.yml.erb'),
    mode    => '0640',
  }

  file { "${gitlab::params::git_home}/gitlab/config/resque.yml":
    ensure  => file,
    content => template('gitlab/resque.yml.erb'),
  }

  exec { 'install gitlab':
    command => "bundle install --without development aws test ${gitlab::params::gitlab_without_gems} --deployment",
    cwd     => "${gitlab::params::git_home}/gitlab",
    unless  => "/usr/bin/test -f ${gitlab::params::git_home}/.git_setup_done",
    timeout => 0,
    require => [
      File["${gitlab::params::git_home}/gitlab/config/database.yml"],
      File["${gitlab::params::git_home}/gitlab/config/unicorn.rb"],
      File["${gitlab::params::git_home}/gitlab/config/gitlab.yml"],
      File["${gitlab::params::git_home}/gitlab/config/resque.yml"],
    ],
  }

  exec { 'setup gitlab database':
    command => '/usr/bin/yes yes | bundle exec rake gitlab:setup RAILS_ENV=production',
    cwd     => "${gitlab::params::git_home}/gitlab",
    unless  => "/usr/bin/test -f ${gitlab::params::git_home}/.git_setup_done",
    creates => "${gitlab::params::git_home}/.gitlab_setup_done",
    require => Exec['install gitlab'],
  }

  file { "${gitlab::params::git_home}/.gitlab_setup_done":
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    require => Exec['setup gitlab database'],
  }
}
