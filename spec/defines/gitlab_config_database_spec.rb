require 'spec_helper'

describe 'gitlab::config::database', :type => :define do

  let(:title) { 'gitlab' }

  context 'mysql' do
    let (:params) {
      {
        :database => 'gitlab_db',
        :group    => 'git',
        :host     => 'localhost',
        :owner    => 'git',
        :password => 'changeme',
        :path     => '/home/git/gitlab/config/database.yml',
        :port     => '5432',
        :type     => 'mysql',
        :username => 'gitlab_user'
      }
    }

    it { should contain_file('/home/git/gitlab/config/database.yml').with(
      :ensure => 'file',
      :owner  => 'git',
      :group  => 'git'
    )}
    it { should contain_file('/home/git/gitlab/config/database.yml').with_content(/^\s*adapter: mysql2$/)}
    it { should contain_file('/home/git/gitlab/config/database.yml').with_content(/^\s*encoding: utf8$/)}
    it { should contain_file('/home/git/gitlab/config/database.yml').with_content(/^\s*database: gitlab_db$/)}
    it { should contain_file('/home/git/gitlab/config/database.yml').with_content(/^\s*username: gitlab_user$/)}
    it { should contain_file('/home/git/gitlab/config/database.yml').with_content(/^\s*password: 'changeme'$/)}
    it { should contain_file('/home/git/gitlab/config/database.yml').with_content(/^\s*host: localhost$/)}
  end

  context 'postgresql' do
    let (:params) {
      {
        :database => 'gitlab_db',
        :group    => 'git',
        :host     => 'localhost',
        :owner    => 'git',
        :password => 'changeme',
        :path     => '/home/git/gitlab/config/database.yml',
        :port     => '5432',
        :type     => 'pgsql',
        :username => 'gitlab_user'
      }
    }
    it { should contain_file('/home/git/gitlab/config/database.yml').with_content(/^\s*adapter: postgresql$/)}
    it { should contain_file('/home/git/gitlab/config/database.yml').with_content(/^\s*encoding: unicode$/)}
    it { should contain_file('/home/git/gitlab/config/database.yml').with_content(/^\s*database: gitlab_db$/)}
    it { should contain_file('/home/git/gitlab/config/database.yml').with_content(/^\s*username: gitlab_user$/)}
    it { should contain_file('/home/git/gitlab/config/database.yml').with_content(/^\s*password: 'changeme'$/)}
    it { should contain_file('/home/git/gitlab/config/database.yml').with_content(/^\s*host: localhost$/)}
    it { should contain_file('/home/git/gitlab/config/database.yml').with_content(/^\s*port: 5432$/)}
  end
end
