# Class:: gitlab::install
#
#
class gitlab::install inherits gitlab {

  $gitlab_without_gems = $gitlab_dbtype ? {
    'mysql' => 'postgres',
    'pgsql' => 'mysql',
    default => '',
  }

  Exec {
    user => $git_user,
    path => $exec_path,
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
    mode    => '0640',
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

  file { "${git_home}/gitlab/config/initializers/rack_attack.rb":
    ensure => file,
    source => "${git_home}/gitlab/config/initializers/rack_attack.rb.example"
  }

  exec { 'install gitlab':
    command => "bundle install --without development aws test ${gitlab_without_gems} --deployment",
    cwd     => "${git_home}/gitlab",
    unless  => 'bundle check',
    timeout => 0,
    tries => 10,
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
    creates => "${git_home}/.gitlab_setup_done",
    require => Exec['install gitlab'],
    notify  => Exec['precompile assets'],
  }

  exec { 'precompile assets':
    command     => 'bundle exec rake assets:precompile RAILS_ENV=production',
    cwd         =>  "${git_home}/gitlab",
    refreshonly =>  true,
  }

  file {
    "${git_home}/.gitlab_setup_done":
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      require => Exec['setup gitlab database'];
  }

}
