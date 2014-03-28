require 'spec_helper'

# Gitlab
describe 'gitlab' do

  ## Parameter set
  # a non-default common parameter set
  let :params_set do
    {
      :git_user    => 'gitlab',
      :git_home    => '/srv/gitlab',
      :git_comment => 'Labfooboozoo',
      :git_email   => 'gitlab@fooboozoo.fr',
      :git_proxy   => 'http://proxy.fooboozoo.fr:3128'
    }
  end

  ## Gitlab::setup
  describe 'gitlab::setup' do

    ### User, gitconfig, home and satellites
    describe 'user, home, gitconfig and GitLab satellites' do
      context 'with default params' do
        it { should contain_user('git').with(
          :ensure   => 'present',
          :shell    => '/bin/bash',
          :password => '*',
          :home     => '/home/git',
          :comment  => 'GitLab',
          :system   => true
        )}
        it { should contain_file('/home/git/.gitconfig').with_content(/^\s*name = "GitLab"$/)}
        it { should contain_file('/home/git/.gitconfig').with_content(/^\s*email = git@someserver.net$/)}
        it { should_not contain_file('/srv/gitlab/.gitconfig').with_content(/^\s*proxy$/)}
        ['/home/git','/home/git/gitlab-satellites'].each do |file|
          it { should contain_file(file).with(:ensure => 'directory',:mode => '0755')}
        end
      end
      context 'with specifics params' do
        let(:params) { params_set }
        it { should contain_user(params_set[:git_user]).with(
          :ensure   => 'present',
          :shell    => '/bin/bash',
          :password => '*',
          :home     => params_set[:git_home],
          :comment  => params_set[:git_comment],
          :system   => true
        )}
        it { should contain_file('/srv/gitlab/.gitconfig').with_content(/^\s*name = "GitLab"$/)}
        it { should contain_file('/srv/gitlab/.gitconfig').with_content(/^\s*email = #{params_set[:git_email]}$/)}
        it { should contain_file('/srv/gitlab/.gitconfig').with_content(/^\s*proxy = #{params_set[:git_proxy]}$/)}
        ['/srv/gitlab','/srv/gitlab/gitlab-satellites'].each do |file|
          it { should contain_file(file).with(:ensure => 'directory',:mode => '0755')}
        end
      end
    end

    ### Sshkey
    describe  'sshkey (hostfile)' do
      it { should contain_sshkey('localhost').with(
        :ensure       => 'present',
        :host_aliases => 'gitlab.fooboozoo.fr',
        :key          => 'AAAAB3NzaC1yc2EAAAA',
        :type         => 'ssh-rsa'
      )}
    end

    #### Db and devel packages
    describe 'packages' do
      #### Gems (all dist.)
      describe 'commons gems' do
        it { should contain_package('bundler').with(
          :ensure   => 'installed',
          :provider => 'gem'
        )}
        it { should contain_package('charlock_holmes').with(
          :ensure   => '0.6.9.4',
          :provider => 'gem'
        )}
      end
    end # packages
  end # gitlab::setup
end # gitlab
