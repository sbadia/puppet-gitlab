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
      :unicorn_worker    => 2
    }
  end

  let :params_url do
    {
      :relative_url_root => '/blahforge'
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
      let(:params) { params_set.merge(params_url) }
        it { is_expected.to contain_file('/home/git/gitlab/config/unicorn.rb').with_content(/^\s*ENV\['RAILS_RELATIVE_URL_ROOT'\] = "\/blahforge"$/)}
    end

  end
end
