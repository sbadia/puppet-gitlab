require 'spec_helper'

describe 'gitlab::config::unicorn', :type => :define do

  let(:title) { 'gitlab' }
  let :params_set do
    {
      :group             => 'git',
      :home              => '/home/git',
      :http_timeout      => 60,
      :owner             => 'git',
      :path              => '/home/git/gitlab/config/unicorn.rb',
      :relative_url_root => false,
      :unicorn_port      => 8080,
      :unicorn_listen    => '127.0.0.1',
      :unicorn_worker    => 2
    }
  end

  describe 'unicorn config' do
    let(:params) { params_set }
    it { is_expected.to contain_file('/home/git/gitlab/config/unicorn.rb').with(
      :ensure => 'file',
      :owner  => 'git',
      :group  => 'git'
    )}
    it { is_expected.to contain_file('/home/git/gitlab/config/unicorn.rb').with_content(/^\s*worker_processes 2$/)}
    it { is_expected.to contain_file('/home/git/gitlab/config/unicorn.rb').with_content(/^\s*working_directory "\/home\/git\/gitlab"$/)}
    it { is_expected.to contain_file('/home/git/gitlab/config/unicorn.rb').with_content(/^\s*listen "127.0.0.1:8080", :tcp_nopush => true$/)}
    it { is_expected.to contain_file('/home/git/gitlab/config/unicorn.rb').with_content(/^\s*listen "\/home\/git\/gitlab\/tmp\/sockets\/gitlab.socket", :backlog => 64$/)}
    it { is_expected.to contain_file('/home/git/gitlab/config/unicorn.rb').with_content(/^\s*timeout 60$/)}
    it { is_expected.to contain_file('/home/git/gitlab/config/unicorn.rb').with_content(/^\s*pid "\/home\/git\/gitlab\/tmp\/pids\/unicorn.pid"$/)}
    it { is_expected.to contain_file('/home/git/gitlab/config/unicorn.rb').with_content(/^\s*stderr_path "\/home\/git\/gitlab\/log\/unicorn.stderr.log"$/)}
    it { is_expected.to contain_file('/home/git/gitlab/config/unicorn.rb').with_content(/^\s*stdout_path "\/home\/git\/gitlab\/log\/unicorn.stdout.log"$/)}


    context 'with non default url-root-path' do
      let(:params) { params_set.merge(:relative_url_root => '/blahforge') }
        it { is_expected.to contain_file('/home/git/gitlab/config/unicorn.rb').with_content(/^\s*ENV\['RAILS_RELATIVE_URL_ROOT'\] = "\/blahforge"$/)}
    end

    context 'with non default unicorn_listen param' do
      let(:params) { params_set.merge(:unicorn_listen => '1.3.3.7') }
        it { is_expected.to contain_file('/home/git/gitlab/config/unicorn.rb').with_content(/^\s*listen "1.3.3.7:8080", :tcp_nopush => true$/)}
    end

    context 'with non default unicorn_port param' do
      let(:params) { params_set.merge(:unicorn_port => '666') }
        it { is_expected.to contain_file('/home/git/gitlab/config/unicorn.rb').with_content(/^\s*listen "127.0.0.1:666", :tcp_nopush => true$/)}
    end


  end
end
