require 'spec_helper'

# Gitlab
describe 'gitlab' do

  ## Parameter set
  # a non-default common parameter set
  let :params_set do
    {
      :git_user            => 'gitlab',
      :git_home            => '/srv/gitlab',
      :git_comment         => 'Labfooboozoo',
      :git_email           => 'gitlab@fooboozoo.fr',
      :git_proxy           => 'http://proxy.fooboozoo.fr:3128',
      :gitlab_ruby_version => '2.0.0',
      :gitlab_manage_rbenv => false,
    }
  end

  ## Gitlab::setup
  describe 'gitlab::setup' do

    ### User, gitconfig, home and satellites
    describe 'user, home, gitconfig and GitLab satellites' do
      context 'with default params' do
        it { is_expected.to contain_user('git').with(
          :ensure   => 'present',
          :shell    => '/bin/bash',
          :password => '*',
          :home     => '/home/git',
          :comment  => 'GitLab',
          :system   => true
        )}
        it { is_expected.to contain_file('/home/git/.gitconfig').with_content(/^\s*name = "GitLab"$/)}
        it { is_expected.to contain_file('/home/git/.gitconfig').with_content(/^\s*email = git@someserver.net$/)}
        it { is_expected.not_to contain_file('/srv/gitlab/.gitconfig').with_content(/^\s*proxy$/)}
        it { is_expected.to contain_file('/home/git').with(:ensure => 'directory', :mode => '0755')}
        it { is_expected.to contain_file('/home/git/gitlab-satellites').with(:ensure => 'directory', :mode => '0750')}
      end
      context 'with specific params' do
        let(:params) { params_set }
        it { is_expected.to contain_user(params_set[:git_user]).with(
          :ensure   => 'present',
          :shell    => '/bin/bash',
          :password => '*',
          :home     => params_set[:git_home],
          :comment  => params_set[:git_comment],
          :system   => true
        )}
        it { is_expected.to contain_file('/srv/gitlab/.gitconfig').with_content(/^\s*name = "GitLab"$/)}
        it { is_expected.to contain_file('/srv/gitlab/.gitconfig').with_content(/^\s*email = #{params_set[:git_email]}$/)}
        it { is_expected.to contain_file('/srv/gitlab/.gitconfig').with_content(/^\s*proxy = #{params_set[:git_proxy]}$/)}
        it { is_expected.to contain_file('/srv/gitlab').with(:ensure => 'directory',:mode => '0755')}
        it { is_expected.to contain_file('/srv/gitlab/gitlab-satellites').with(:ensure => 'directory',:mode => '0750')}
      end
    end

    ### Ruby
    describe 'rbenv' do
      context 'with default params' do
        it { is_expected.to contain_rbenv__install('git').with(
                      :group => 'git',
                      :home  => '/home/git'
                    )}
        it { is_expected.to contain_file('/home/git/.bashrc').with(
                      :ensure  => 'link',
                      :target  => '/home/git/.profile',
                      :require => 'Rbenv::Install[git]'
                    )}
        it { is_expected.to contain_rbenv__compile('gitlab/ruby').with(
                      :user   => 'git',
                      :home   => '/home/git',
                      :ruby   => '2.1.6',
                      :global => true,
                      :notify => ['Exec[install gitlab-shell]', 'Exec[install gitlab]']
                    )}

      end
      context 'with specific params' do
        let(:params) { params_set }
        it { is_expected.not_to contain_rbenv__install(params_set[:git_user]) }
        it { is_expected.not_to contain_file('/srv/gitlab/.bashrc') }
        it { is_expected.not_to contain_rbenv__compile('gitlab/ruby') }
      end
    end

    ### Sshkey
    describe 'sshkey (hostfile)' do
      it { is_expected.to contain_sshkey('localhost').with(
        :ensure       => 'present',
        :host_aliases => 'gitlab.fooboozoo.fr',
        :key          => 'AAAAB3NzaC1yc2EAAAA',
        :type         => 'ssh-rsa'
      )}
    end

    ### Packages setup
    #= Packages helper
    p = {
      'Debian' => {
        'db_packages' => {
          'mysql' => {
             '6' => ['libmysql++-dev','libmysqlclient-dev'],
             '7' => ['libmysql++-dev','libmysqlclient-dev'],
          },
          'pgsql' => {
             '6' => ['libpq-dev', 'postgresql-client'],
             '7' => ['libpq-dev', 'postgresql-client'],
          },
        },
        'system_packages' => ['libicu-dev', 'python2.7','python-docutils',
                              'libxml2-dev','libxslt1-dev','python-dev'],
      },
      'RedHat' => {
        'db_packages' => {
          'mysql' => {
            '6' => ['mysql-devel'],
            '7' => ['mariadb-devel'],
          },
          'pgsql' => {
            '6' => ['postgresql-devel'],
            '7' => ['postgresql-devel'],
          },
        },
        'system_packages' => ['libicu-devel','perl-Time-HiRes','libxml2-devel',
                              'libxslt-devel','python-devel','libcurl-devel',
                              'readline-devel','openssl-devel','zlib-devel',
                              'libyaml-devel','patch','gcc-c++'],
      }
    }

    #### Db and devel packages
    describe 'packages' do
      #= On each distro
      ['Debian','RedHat'].each do |distro|
        #= With each dbtype
        ['mysql','pgsql'].each do |dbtype|
          ['6', '7'].each do |majrelease|
            context "for #{dbtype} devel on #{distro}" do
              let(:facts) {{ :osfamily => distro, :processorcount => '2', :operatingsystemmajrelease => majrelease }}
              let(:params) {{ :gitlab_dbtype => dbtype }}
              p[distro]['db_packages'][dbtype][majrelease].each do |pkg|
                it { is_expected.to contain_package(pkg) }
              end
            end
          end
        end
        context "for devel dependencies on #{distro}" do
          let(:facts) {{ :osfamily => distro, :processorcount => '2' }}
          p[distro]['system_packages'].each do |pkg|
            it { is_expected.to contain_package(pkg) }
          end

          it { is_expected.to contain_class('git') }
          it { is_expected.to contain_package('git') }
        end
      end
      #### Gems (all dist.)
      describe 'commons gems' do
        context 'with default params' do
          it { is_expected.to contain_rbenv__gem('charlock_holmes').with(
            :ensure   => '0.6.9.4'
          )}
        end
        context 'with specific params' do
          let(:params) { params_set }
          it { is_expected.not_to contain_rbenv__gem('charlock_holmes') }
        end
      end
      #### Commons packages (all dist.)
      describe 'commons packages' do
        ['postfix','curl'].each do |pkg|
          it { is_expected.to contain_package(pkg) }
        end
      end
    end # packages
  end # gitlab::setup
end # gitlab
