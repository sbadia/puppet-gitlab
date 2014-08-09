require 'spec_helper'

# Gitlab
describe 'gitlab::ci' do
  let(:facts) {{
    :osfamily       => 'Debian',
    :fqdn           => 'gitlabci.fooboozoo.fr'
  }}

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
        it { should contain_user('gitlab_ci').with(
          :ensure   => 'present',
          :shell    => '/bin/bash',
          :password => '*',
          :home     => '/home/gitlab_ci',
          :comment  => 'GitLab CI',
          :system   => true
        )}
        it { should contain_file('/home/gitlab_ci').with(:ensure => 'directory', :mode => '0755')}
      end
      context 'with specifics params' do
        let(:params) { params_set }
        it { should contain_user(params_set[:ci_user]).with(
          :ensure   => 'present',
          :shell    => '/bin/bash',
          :password => '*',
          :home     => params_set[:ci_home],
          :comment  => params_set[:ci_comment],
          :system   => true
        )}
        it { should contain_file('/srv/ci').with(:ensure => 'directory',:mode => '0755')}
      end
    end

  end # gitlab::ci::setup
end # gitlab
