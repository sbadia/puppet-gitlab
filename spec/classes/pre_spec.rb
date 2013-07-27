require 'spec_helper'

describe 'gitlab', :type => :class do
  context 'gitlab::pre validation' do
    ['Debian','RedHat'].each do |distro|
      context  "while on #{distro} (Agnostic tests)" do
        let (:facts) { {  :osfamily => distro, :fqdn => 'fqdn.host.name' } }
        include_context "gitlab_shared"
        let (:pre_condition) { global_gitlab_variables }
        let (:params) { { :gitlab_dbpwd => 'foo@foo.com', :git_email => 'foo@site.com' } }
        context 'Classes:' do
          ['gitlab::pre'].each do |classes|
            it "should contain class #{classes}" do
              should contain_class(classes)
            end
          end
        end
        context 'Execs:' do
        end
        context 'Files:' do
          it 'shoule create the git user\'s homedir' do
            should contain_file('/home/git').with(
              :path=>'/home/git',
              :ensure=>'directory',
              :owner=>'git',
              :group=>'git',
              :mode=>'0755'
            )
          end
        end
        context 'Misc Resources:' do
          it 'should contain the git user' do
            should contain_user('git').with(
              :ensure=>'present',
              :shell=>'/bin/bash',
              :password=>'*',
              :home=>'/home/git',
              :comment=>'GitLab',
              :system=>true
            )
          end
        end
        context 'Packages:' do
          ['curl','git','openssh-server','postfix',].each do |packages|
            it { should contain_package(packages) }
          end
        end
      end
    end
    context 'While on Debian (specific tests)' do
      let (:facts) { {  :osfamily => 'Debian' } }
        include_context "gitlab_shared"
        let (:pre_condition) { global_gitlab_variables }
        let (:params) { { :gitlab_dbpwd => 'foo@foo.com', :git_email => 'foo@site.com' } }
      context 'Files:' do
        it 'should create a symlink from /usr/bin/python to /usr/bin/python2' do
          should contain_file('/usr/bin/python2').with(
            :ensure => 'link',
            :target => '/usr/bin/python'
          )
        end
      end
      context 'Packages:' do
        ['git-core','libicu-dev','python2.7','libxml2-dev','libxslt1-dev','python-dev'].each do |packages|
          it  { should contain_package("#{packages}")}
        end

        context 'when configured to use mysql' do
          let (:params) { { :gitlab_dbpwd => 'foo@foo.com', :git_email => 'foo@site.com',:gitlab_dbtype => 'mysql' } }
          it 'should contain the dev packages for mysql' do
            should contain_package('libmysql++-dev')
            should contain_package('libmysqlclient-dev')
          end
        end
        context 'when configured to use postgres' do
          let (:params) { { :gitlab_dbpwd => 'foo@foo.com', :git_email => 'foo@site.com',:gitlab_dbtype => 'pgsql' } }
          it 'should contain the dev packages for postgres' do
            should contain_package('libpq-dev')
            should contain_package('postgresql-client')
          end
        end
      end
    end
    context 'while on RedHat (specific tests)' do
      let (:facts) { {  :osfamily => 'RedHat' } }
        include_context "gitlab_shared"
        let (:pre_condition) { global_gitlab_variables }
        let (:params) { { :gitlab_dbpwd => 'foo@foo.com', :git_email => 'foo@site.com' } }
      context 'Files:' do
      end
      context 'Packages:' do
        it 'should contain the necessary devel packages' do
          ['libcurl-devel', 'libicu-devel', 'libxml2-devel', 'libxslt-devel', 'libyaml-devel', 'openssl-devel', 'perl-Time-HiRes', 'python-devel', 'readline-devel', 'zlib-devel'].each do |packages|
            should contain_package("#{packages}")
          end
        end
        it 'should contain the necessary compilers packages' do
          ['gcc', 'gcc-c++'].each do |packages|
            should contain_package("#{packages}")
          end
        end
        it { }
        context 'when configured to use mysql' do
          let (:params) { { :gitlab_dbpwd => 'foo@foo.com', :git_email => 'foo@site.com',:gitlab_dbtype => 'mysql' } }
          it 'should contain the dev packages for mysql' do
            should contain_package('mysql-devel')
          end
        end
        context 'when configured to use postgres' do
          let (:params) { { :gitlab_dbpwd => 'foo@foo.com', :git_email => 'foo@site.com',:gitlab_dbtype => 'pgsql' } }
          it 'should contain the dev packages for postgres' do
            should contain_package('postgresql-devel')
          end
        end
      end
    end
  end
end