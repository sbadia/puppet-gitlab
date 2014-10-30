#
class gitlab::ci::install inherits gitlab::ci {

  $without_gems = $gitlab_dbtype ? {
    'mysql' => 'postgres',
    'pgsql' => 'mysql',
    default => '',
  }

  Exec {
    user => $ci_user,
    path => $exec_path,
  }

  File {
    owner => $ci_user,
    group => $ci_user,
  }

  gitlab::config::database { 'gitlab-ci':
    database => $gitlab_dbname,
    group    => $ci_user,
    host     => $gitlab_dbhost,
    owner    => $ci_user,
    password => $gitlab_dbpwd,
    path     => "${ci_home}/gitlab-ci/config/database.yml",
    port     => $gitlab_dbport,
    type     => $gitlab_dbtype,
    username => $gitlab_dbuser,
  }

  gitlab::config::unicorn { 'gitlab-ci':
    group             => $ci_user,
    home              => $ci_home,
    http_timeout      => $gitlab_http_timeout,
    owner             => $ci_user,
    path              => "${ci_home}/gitlab-ci/config/unicorn.rb",
    relative_url_root => $gitlab_relative_url_root,
    unicorn_listen    => $gitlab_unicorn_listen,
    unicorn_port      => $gitlab_unicorn_port,
    unicorn_worker    => $gitlab_unicorn_worker,
  }

  gitlab::config::resque { 'gitlab-ci':
    group      => $ci_user,
    owner      => $ci_user,
    path       => "${ci_home}/gitlab-ci/config/resque.yml",
    redis_host => $gitlab_redishost,
    redis_port => $gitlab_redisport,
  }

  file { "${ci_home}/gitlab-ci/config/application.yml":
    ensure  => file,
    content => template('gitlab/gitlab-ci-application.yml.erb'),
    mode    => '0640',
    notify  => Service['gitlab_ci'],
  }

  exec { 'install gitlab-ci':
    command => "bundle install --without development aws test ${without_gems} ${bundler_flags}",
    cwd     => "${ci_home}/gitlab-ci",
    unless  => 'bundle check',
    timeout => 0,
    require => [
      Gitlab::Config::Database['gitlab-ci'],
      Gitlab::Config::Unicorn['gitlab-ci'],
      File["${ci_home}/gitlab-ci/config/application.yml"],
      Gitlab::Config::Resque['gitlab-ci'],
    ],
    notify  => Exec['run gitlab-ci migrations'],
  }

  exec { 'setup gitlab-ci database':
    command => "/usr/bin/yes yes | bundle exec rake setup RAILS_ENV=production && touch ${ci_home}/.gitlab-ci_setup_done",
    cwd     => "${ci_home}/gitlab-ci",
    creates => "${ci_home}/.gitlab-ci_setup_done",
    require => Exec['install gitlab-ci'],
    before  => Exec['run gitlab-ci migrations'],
    notify  => [
      Exec['precompile gitlab-ci assets'],
      Exec['run gitlab-ci schedules']
    ],
  }

  exec { 'precompile gitlab-ci assets':
    command     => 'bundle exec rake assets:clean assets:precompile cache:clear RAILS_ENV=production',
    cwd         => "${ci_home}/gitlab-ci",
    refreshonly => true,
  }

  exec { 'run gitlab-ci migrations':
    command     => 'bundle exec rake db:migrate RAILS_ENV=production',
    cwd         => "${ci_home}/gitlab-ci",
    refreshonly => true,
    notify      => Exec['precompile gitlab-ci assets'],
  }

  exec { 'run gitlab-ci schedules':
    command     => 'bundle exec whenever -w RAILS_ENV=production',
    cwd         => "${ci_home}/gitlab-ci",
    refreshonly => true,
  }

}
