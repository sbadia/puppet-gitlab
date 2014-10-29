require 'spec_helper'

# Gitlab
describe 'gitlab' do

  ## Parameter set
  # a non-default common parameter set
  let :params_set do
    {
      :git_user               => 'gitlab',
      :git_home               => '/srv/gitlab',
      :gitlab_sources         => 'https://github.com/gitlabhq/gitlabhq',
      :gitlab_branch          => '4-2-stable',
      :gitlabshell_sources    => 'https://github.com/gitlabhq/gitlab-shell',
      :gitlabshell_branch     => 'v1.2.3',
    }
  end

  ## Gitlab::package
  describe 'gitlab::package' do
    describe 'get gitlab{-shell} sources' do
      context 'with default params' do
        it { is_expected.to contain_vcsrepo('/home/git/gitlab').with(
          :ensure   => 'present',
          :user     => 'git',
          :provider => 'git',
          :source   => 'git://github.com/gitlabhq/gitlabhq.git',
          :revision => '7-4-stable'
        )}
        it { is_expected.to contain_vcsrepo('/home/git/gitlab-shell').with(
          :ensure   => 'present',
          :user     => 'git',
          :provider => 'git',
          :source   => 'git://github.com/gitlabhq/gitlab-shell.git',
          :revision => 'v2.0.1'
        )}
      end
      context 'with specifics params' do
        let(:params) { params_set }
        it { is_expected.to contain_vcsrepo("#{params_set[:git_home]}/gitlab").with(
          :ensure   => 'present',
          :user     => params_set[:git_user],
          :provider => 'git',
          :source   => params_set[:gitlab_sources],
          :revision => params_set[:gitlab_branch]
        )}
        it { is_expected.to contain_vcsrepo("#{params_set[:git_home]}/gitlab-shell").with(
          :ensure   => 'present',
          :user     => params_set[:git_user],
          :provider => 'git',
          :source   => params_set[:gitlabshell_sources],
          :revision => params_set[:gitlabshell_branch]
        )}
      end
    end # get gitlab sources
  end # gitlab::package
end # gitlab
