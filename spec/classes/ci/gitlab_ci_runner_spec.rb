require 'spec_helper'

describe 'gitlab::ci::runner' do

  let :params do
    {
      :ci_server_url      => 'ci.fooboozoo.fr',
      :registration_token => 'replaceme'
    }
  end

  it { should contain_vcsrepo('/home/gitlab_ci_runner/gitlab-ci-runner').with(
    :ensure   => 'present',
    :user     => 'gitlab_ci_runner',
    :provider => 'git',
    :source   => 'https://gitlab.com/gitlab-org/gitlab-ci-runner.git',
    :revision => '5-0-stable'
  )}

  it { should contain_user('gitlab_ci_runner').with(
    :ensure     => 'present',
    :comment    => 'GitLab CI Runner',
    :home       => '/home/gitlab_ci_runner',
    :managehome => true,
    :password   => '*',
    :shell      => '/bin/bash',
    :system     => true
  )}

  it { should contain_rbenv__install('gitlab_ci_runner').with(
    :group => 'gitlab_ci_runner',
    :home  => '/home/gitlab_ci_runner'
  )}

  it { should contain_file('/home/gitlab_ci_runner/.bashrc').with(
    :ensure  => 'file',
    :content => 'source /home/gitlab_ci_runner/.rbenvrc',
    :require => 'Rbenv::Install[gitlab_ci_runner]'
  )}

  it { should contain_rbenv__compile('gitlab-ci-runner/ruby').with(
    :user   => 'gitlab_ci_runner',
    :home   => '/home/gitlab_ci_runner',
    :ruby   => '2.1.2',
    :global => true,
    :notify => 'Exec[install gitlab-ci-runner]'
  )}

  it { should contain_exec('install gitlab-ci-runner').with(
    :user    => 'gitlab_ci_runner',
    :path    => '/home/gitlab_ci_runner/.rbenv/shims:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
    :command => "bundle install --deployment",
    :unless  => 'bundle check',
    :cwd     => '/home/gitlab_ci_runner/gitlab-ci-runner',
    :timeout => 0,
    :notify  => 'Exec[run gitlab-ci-runner setup]'
  )}

  it { should contain_exec('run gitlab-ci-runner setup').with(
    :user        => 'gitlab_ci_runner',
    :path        => '/home/gitlab_ci_runner/.rbenv/shims:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
    :command     => 'bundle exec ./bin/setup',
    :cwd         => '/home/gitlab_ci_runner/gitlab-ci-runner',
    :refreshonly => true,
    :environment => ["CI_SERVER_URL=#{params[:ci_server_url]}", "REGISTRATION_TOKEN=#{params[:registration_token]}"]
  )}

  it { should contain_file('/etc/init.d/gitlab_ci_runner').with(
    :ensure  => 'file',
    :owner   => 'root',
    :group   => 'root',
    :mode    => '0755',
    :source  => "/home/gitlab_ci_runner/gitlab-ci-runner/lib/support/init.d/gitlab_ci_runner"
  )}

  it { should contain_service('gitlab_ci_runner').with(
    :ensure     => 'running',
    :hasstatus  => 'true',
    :hasrestart => 'true',
    :enable     => 'true'
  )}

end
