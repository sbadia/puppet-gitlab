#
class gitlab::ci::runner (
  $ci_server_url,
  $registration_token,
  $ensure              = 'present',
  $user                = 'gitlab_ci_runner',
  $user_home           = '/home/gitlab_ci_runner',
  $source              = 'https://gitlab.com/gitlab-org/gitlab-ci-runner.git',
  $branch              = '5-0-stable',
  $exec_path           = '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin'
){

  user { $user:
    ensure     => $ensure,
    comment    => 'GitLab CI Runner',
    home       => $user_home,
    managehome => true,
    password   => '*',
    shell      => '/bin/bash',
    system     => true,
  }

  vcsrepo { "${user_home}/gitlab-ci-runner":
    ensure   => $ensure,
    source   => $source,
    revision => $branch,
    provider => 'git',
    user     => $user,
  }

  Exec {
    user => $user,
    path => $exec_path,
  }

  exec { 'install gitlab-ci-runner':
    command => 'bundle install --deployment',
    cwd     => "${user_home}/gitlab-ci-runner",
    unless  => 'bundle check',
    timeout => 0,
    notify  => Exec['run gitlab-ci-runner setup'],
  }

  exec { 'run gitlab-ci-runner setup':
    command     => 'bundle exec ./bin/setup',
    cwd         => "${user_home}/gitlab-ci-runner",
    timeout     => 0,
    refreshonly => true,
    environment => ["CI_SERVER_URL=${ci_server_url}", "REGISTRATION_TOKEN=${registration_token}"],
  }

  file { '/etc/init.d/gitlab_ci_runner':
    ensure  => file,
    source  => "${user_home}/gitlab-ci-runner/lib/support/init.d/gitlab_ci_runner",
    owner   => root,
    group   => root,
    mode    => '0755',
  }

  service { 'gitlab_ci_runner':
    ensure     => running,
    hasstatus  => true,
    hasrestart => true,
    enable     => true,
  }

  User[$user] ->
  Vcsrepo["${user_home}/gitlab-ci-runner"] ->
  Exec['install gitlab-ci-runner'] ->
  File['/etc/init.d/gitlab_ci_runner'] ->
  Service['gitlab_ci_runner']

}
