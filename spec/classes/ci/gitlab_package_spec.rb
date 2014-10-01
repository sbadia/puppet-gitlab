require 'spec_helper'

# Gitlab
describe 'gitlab::ci' do

  ## Parameter set
  # a non-default common parameter set
  let :params_set do
    {
      :ci_user          => 'ci',
      :ci_home          => '/srv/ci',
      :gitlabci_sources => 'https://github.com/gitlabhq/gitlabci',
      :gitlabci_branch  => '4-2-stable'
    }
  end

  ## Gitlab::package
  describe 'gitlab::ci::package' do
    describe 'get gitlabci sources' do
      context 'with default params' do
        it { is_expected.to contain_vcsrepo('/home/gitlab_ci/gitlab-ci').with(
          :ensure   => 'present',
          :user     => 'gitlab_ci',
          :provider => 'git',
          :source   => 'git://github.com/gitlabhq/gitlab-ci.git',
          :revision => '5-0-stable'
        )}
      end
      context 'with specifics params' do
        let(:params) { params_set }
        it { is_expected.to contain_vcsrepo("#{params_set[:ci_home]}/gitlab-ci").with(
          :ensure   => 'present',
          :user     => params_set[:ci_user],
          :provider => 'git',
          :source   => params_set[:gitlabci_sources],
          :revision => params_set[:gitlabci_branch]
        )}
      end
    end # get gitlab sources
  end # gitlab::ci::package
end # gitlab
