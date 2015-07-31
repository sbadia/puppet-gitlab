# Class:: gitlab::install
#
#
class gitlab::install inherits gitlab {

  # note that this is *without*
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
    group => $git_group,
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
  gitlab::config::database { 'gitlab':
    database => $gitlab_dbname,
    group    => $git_group,
    host     => $gitlab_dbhost,
    owner    => $git_user,
    password => $gitlab_dbpwd,
    path     => "${git_home}/gitlab/config/database.yml",
    port     => $gitlab_dbport,
    type     => $gitlab_dbtype,
    username => $gitlab_dbuser,
  }

  gitlab::config::unicorn { 'gitlab':
    group             => $git_group,
    home              => $git_home,
    http_timeout      => $gitlab_http_timeout,
    owner             => $git_user,
    path              => "${git_home}/gitlab/config/unicorn.rb",
    relative_url_root => $gitlab_relative_url_root,
    unicorn_listen    => $gitlab_unicorn_listen,
    unicorn_port      => $gitlab_unicorn_port,
    unicorn_worker    => $gitlab_unicorn_worker,
  }

  file { "${git_home}/gitlab/config/gitlab.yml":
    ensure  => file,
    content => template('gitlab/gitlab.yml.erb'),
    mode    => '0640',
  }

  gitlab::config::resque { 'gitlab':
    group      => $git_group,
    owner      => $git_user,
    path       => "${git_home}/gitlab/config/resque.yml",
    redis_host => $gitlab_redishost,
    redis_port => $gitlab_redisport,
  }

  file { "${git_home}/gitlab/config/initializers/rack_attack.rb":
    ensure => file,
    source => "${git_home}/gitlab/config/initializers/rack_attack.rb.example",
  }

  if $gitlab_relative_url_root or $use_exim {
    file { "${git_home}/gitlab/config/application.rb":
      ensure  => file,
      content => template('gitlab/application.rb.erb'),
    }
  }

  if($gitlab_bundler_jobs == '1') {
    $gitlab_bundler_jobs_flag = ''
  } else {
    $gitlab_bundler_jobs_flag = " -j${gitlab_bundler_jobs}"
  }
  exec { 'install gitlab':
    command => "bundle install${gitlab_bundler_jobs_flag} --without development aws test ${gitlab_without_gems} ${gitlab_bundler_flags}",
    cwd     => "${git_home}/gitlab",
    unless  => 'bundle check',
    timeout => 0,
    require => [
      Gitlab::Config::Database['gitlab'],
      Gitlab::Config::Unicorn['gitlab'],
      File["${git_home}/gitlab/config/gitlab.yml"],
      Gitlab::Config::Resque['gitlab'],
    ],
    notify  => Exec['run migrations'],
  }

  exec { 'setup gitlab database':
    command => '/usr/bin/yes yes | bundle exec rake gitlab:setup RAILS_ENV=production',
    cwd     => "${git_home}/gitlab",
    creates => "${gitlab_setup_status_dir}/.gitlab_setup_done",
    require => [
      Exec['install gitlab-shell'],
      Exec['install gitlab'],
    ],
    notify  => Exec['precompile assets'],
    before  => Exec['run migrations'],
  }

  exec { 'precompile assets':
    command     => 'bundle exec rake assets:clean assets:precompile cache:clear RAILS_ENV=production',
    cwd         =>  "${git_home}/gitlab",
    refreshonly =>  true,
  }

  exec { 'run migrations':
    command     => 'bundle exec rake db:migrate RAILS_ENV=production',
    cwd         =>  "${git_home}/gitlab",
    refreshonly =>  true,
    notify      => Exec['precompile assets'],
  }

  file {
    "${gitlab_setup_status_dir}/.gitlab_setup_done":
      ensure  => file,
      owner   => 'root',
      group   => 'root',
      require => Exec['setup gitlab database'];
  }

  if ($gitlab_manage_rbenv) {
    #gitlab-shell hooks must be updated to use the Ruby version installed by rbenv.
    #Use a script because different versions of gitlab-shell have a varying
    #set of hooks
    $ruby_cmd="${git_home}/.rbenv/shims/ruby"
    exec { 'fix ruby paths in gitlab-shell hooks':
      command => "ruby -p -i -e '\$_.sub!(/^#!.*ruby\$/,\"#!${ruby_cmd}\")' *",
      cwd     => "${git_home}/gitlab-shell/hooks",
      onlyif  => "head -q -n 1 * | egrep -v '^#!${ruby_cmd}\$'",
      require => Exec['install gitlab-shell'],
    }
  }

}
