require 'spec_helper'

# Gitlab
describe 'gitlab' do
  let(:facts) {{
    :osfamily  => 'Debian',
    :fqdn      => 'gitlab.fooboozoo.fr',
    :processorcount => '2',
    :sshrsakey => 'AAAAB3NzaC1yc2EAAAA'
  }}

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
        it { should contain_vcsrepo('/home/git/gitlab').with(
          :ensure   => 'present',
          :user     => 'git',
          :provider => 'git',
          :source   => 'git://github.com/gitlabhq/gitlabhq.git',
          :revision => '6-9-stable'
        )}
        it { should contain_vcsrepo('/home/git/gitlab-shell').with(
          :ensure   => 'present',
          :user     => 'git',
          :provider => 'git',
          :source   => 'git://github.com/gitlabhq/gitlab-shell.git',
          :revision => 'v1.9.4'
        )}
      end
      context 'with specifics params' do
        let(:params) { params_set }
        it { should contain_vcsrepo("#{params_set[:git_home]}/gitlab").with(
          :ensure   => 'present',
          :user     => params_set[:git_user],
          :provider => 'git',
          :source   => params_set[:gitlab_sources],
          :revision => params_set[:gitlab_branch]
        )}
        it { should contain_vcsrepo("#{params_set[:git_home]}/gitlab-shell").with(
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
