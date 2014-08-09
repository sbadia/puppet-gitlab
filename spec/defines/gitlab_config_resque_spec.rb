require 'spec_helper'

describe 'gitlab::config::resque', :type => :define do

    let(:title) { 'gitlab' }
    let :params do
      {
        :group      => 'git',
        :owner      => 'git',
        :path       => '/home/git/gitlab/config/resque.yml',
        :redis_host => '127.0.0.1',
        :redis_port => '6379',
      }
    end

    describe 'resque config' do
      it { should contain_file('/home/git/gitlab/config/resque.yml').with(
        :ensure => 'file',
        :owner  => 'git',
        :group  => 'git'
      )}
      it { should contain_file('/home/git/gitlab/config/resque.yml').with_content(/^\s*production: redis:\/\/127.0.0.1:6379$/)}
    end
end
