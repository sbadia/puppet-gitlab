require 'spec_helper'

describe 'gitlab::config::unicorn', :type => :define do

  let(:title) { 'gitlab' }
  let :params do
    {
      :group             => 'git',
      :home              => '/home/git',
      :http_timeout      => 60,
      :owner             => 'git',
      :path              => '/home/git/gitlab/config/unicorn.rb',
      :relative_url_root => false,
      :unicorn_port      => 8080,
      :unicorn_worker    => 2
    }
  end

  describe 'unicorn config' do
    it { should contain_file('/home/git/gitlab/config/unicorn.rb').with(
      :ensure => 'file',
      :owner  => 'git',
      :group  => 'git'
    )}
    it { should contain_file('/home/git/gitlab/config/unicorn.rb').with_content(/^\s*worker_processes 2$/)}
    it { should contain_file('/home/git/gitlab/config/unicorn.rb').with_content(/^\s*working_directory "\/home\/git\/gitlab"$/)}
    it { should contain_file('/home/git/gitlab/config/unicorn.rb').with_content(/^\s*listen "127.0.0.1:8080", :tcp_nopush => true$/)}
    it { should contain_file('/home/git/gitlab/config/unicorn.rb').with_content(/^\s*listen "\/home\/git\/gitlab\/tmp\/sockets\/gitlab.socket", :backlog => 64$/)}
    it { should contain_file('/home/git/gitlab/config/unicorn.rb').with_content(/^\s*timeout 60$/)}
    it { should contain_file('/home/git/gitlab/config/unicorn.rb').with_content(/^\s*pid "\/home\/git\/gitlab\/tmp\/pids\/unicorn.pid"$/)}
    it { should contain_file('/home/git/gitlab/config/unicorn.rb').with_content(/^\s*stderr_path "\/home\/git\/gitlab\/log\/unicorn.stderr.log"$/)}
    it { should contain_file('/home/git/gitlab/config/unicorn.rb').with_content(/^\s*stdout_path "\/home\/git\/gitlab\/log\/unicorn.stdout.log"$/)}
  end

end
