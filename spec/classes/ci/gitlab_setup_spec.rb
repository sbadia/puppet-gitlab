require 'spec_helper'

# Gitlab
describe 'gitlab::ci' do

  ## Parameter set
  # a non-default common parameter set
  let :params_set do
    {
      :ci_user    => 'ci',
      :ci_home    => '/srv/ci',
      :ci_comment => 'ci user'
    }
  end

  ## Gitlab::setup
  describe 'gitlab::ci::setup' do

    ### User, gitconfig, home and satellites
    describe 'user, home' do
      context 'with default params' do
        it { is_expected.to contain_user('gitlab_ci').with(
          :ensure     => 'present',
          :shell      => '/bin/bash',
          :password   => '*',
          :home       => '/home/gitlab_ci',
          :comment    => 'GitLab CI',
          :system     => true,
          :managehome => true
        )}
      end
      context 'with specifics params' do
        let(:params) { params_set }
        it { is_expected.to contain_user(params_set[:ci_user]).with(
          :ensure     => 'present',
          :shell      => '/bin/bash',
          :password   => '*',
          :home       => params_set[:ci_home],
          :comment    => params_set[:ci_comment],
          :system     => true,
          :managehome => true
        )}
      end

      ### Ruby
      describe 'rbenv' do
        context 'with default params' do
          it { is_expected.to contain_rbenv__install('gitlab_ci').with(
                        :group => 'gitlab_ci',
                        :home  => '/home/gitlab_ci'
                      )}
          it { is_expected.to contain_file('/home/gitlab_ci/.bashrc').with(
                        :ensure  => 'file',
                        :content => 'source /home/gitlab_ci/.rbenvrc',
                        :require => 'Rbenv::Install[gitlab_ci]'
                      )}
          it { is_expected.to contain_rbenv__compile('gitlabci/ruby').with(
                        :user   => 'gitlab_ci',
                        :home   => '/home/gitlab_ci',
                        :ruby   => '2.1.2',
                        :global => true,
                        :notify => 'Exec[install gitlab-ci]'
                      )}
        end
      end
    end

  end # gitlab::ci::setup
end # gitlab
