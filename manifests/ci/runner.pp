#
class gitlab::ci::runner (
  $ci_server_url,
  $registration_token,
  $ensure              = 'present',
  $branch              = '5-0-stable',
  $exec_path           = '/home/gitlab_ci_runner/.rbenv/shims:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
  $ruby_version        = '2.1.2',
  $source              = 'https://gitlab.com/gitlab-org/gitlab-ci-runner.git',
  $user                = 'gitlab_ci_runner',
  $user_home           = '/home/gitlab_ci_runner',
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

  case $::osfamily {
    'Debian': {
      $system_packages = ['libicu-dev']
    }
    'RedHat': {
      $system_packages = ['libicu-devel']
    }
    default: {
      fail("${::osfamily} not supported yet")
    }
  }

  ensure_packages($system_packages)

  file { "${user_home}/.bashrc":
    ensure  => file,
    content => "source ${user_home}/.rbenvrc",
    require => Rbenv::Install['gitlab_ci_runner']
  }

  rbenv::install { $user:
    group   => $user,
    home    => $user_home,
  }

  rbenv::compile { 'gitlab-ci-runner/ruby':
    user   => $user,
    home   => $user_home,
    ruby   => $ruby_version,
    global => true,
    notify => Exec['install gitlab-ci-runner'],
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
  Rbenv::Install[$user] ->
  Rbenv::Compile['gitlab-ci-runner/ruby'] ->
  Exec['install gitlab-ci-runner'] ->
  File['/etc/init.d/gitlab_ci_runner'] ->
  Service['gitlab_ci_runner']

}
