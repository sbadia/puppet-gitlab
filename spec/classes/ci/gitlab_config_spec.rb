require 'spec_helper'

# Gitlab
describe 'gitlab::ci' do
  let(:facts) {{
    :osfamily => 'Debian',
    :fqdn     => 'gitlab-ci.fooboozoo.fr',
  }}

  ## Parameter set
  # a non-default common parameter set
  let :params_set do
    {
      :ci_user             => 'ci',
      :ci_home             => '/srv/ci',
      :gitlab_http_timeout => '300'
    }
  end

  # a non-default parameter set for SSL support
  let :params_ssl do
    {
      :gitlab_ssl             => true,
      :gitlab_ssl_self_signed => true
    }
  end

  ### Gitlab::config
  describe 'gitlab::config' do
    context 'with default params' do
      describe 'nginx config' do
        it { should contain_file('/etc/nginx/conf.d/gitlab-ci.conf').with(
          :ensure => 'file',
          :owner  => 'root',
          :group  => 'root',
          :mode   => '0644'
        )}
        it { should contain_file('/etc/nginx/conf.d/gitlab-ci.conf').with_content(/^\s*server unix:\/home\/gitlab_ci\/gitlab-ci\/tmp\/sockets\/gitlab-ci.socket;$/)}
        it { should contain_file('/etc/nginx/conf.d/gitlab-ci.conf').with_content(/^\s*listen 80;$/)}
        it { should contain_file('/etc/nginx/conf.d/gitlab-ci.conf').with_content(/^\s*server_name gitlab-ci.fooboozoo.fr;$/)}
        it { should contain_file('/etc/nginx/conf.d/gitlab-ci.conf').with_content(/^\s*server_tokens off;$/)}
        it { should contain_file('/etc/nginx/conf.d/gitlab-ci.conf').with_content(/^\s*root \/home\/gitlab_ci\/gitlab-ci\/public;$/)}
        it { should contain_file('/etc/nginx/conf.d/gitlab-ci.conf').with_content(/^\s*proxy_read_timeout 60;$/)}
        it { should contain_file('/etc/nginx/conf.d/gitlab-ci.conf').with_content(/^\s*proxy_connect_timeout 60;$/)}
      end # nginx config
      describe 'gitlab init' do
        it { should contain_file('/etc/init.d/gitlab_ci').with(
          :ensure  => 'file',
          :owner   => 'root',
          :group   => 'root',
          :mode    => '0755',
          :source  => "/home/gitlab_ci/gitlab-ci/lib/support/init.d/gitlab_ci"
        )}
      end # gitlab init
      describe 'gitlab-ci directories' do
        ['gitlab-ci/tmp','gitlab-ci/tmp/pids','gitlab-ci/tmp/sockets','gitlab-ci/log','gitlab-ci/public'].each do |dir|
          it { should contain_file("/home/gitlab_ci/#{dir}").with(
            :ensure => 'directory',
            :mode   => '0755'
          )}
        end
      end # gitlab directories
    end # default params
    context 'with specifics params' do
      let(:params) { params_set }
      describe 'nginx config' do
        it { should contain_file('/etc/nginx/conf.d/gitlab-ci.conf').with(
          :ensure => 'file',
          :owner  => 'root',
          :group  => 'root',
          :mode   => '0644'
        )}
        it { should contain_file('/etc/nginx/conf.d/gitlab-ci.conf').with_content(/^\s*server unix:#{params_set[:ci_home]}\/gitlab-ci\/tmp\/sockets\/gitlab-ci.socket;$/)}
        it { should contain_file('/etc/nginx/conf.d/gitlab-ci.conf').with_content(/^\s*server_name gitlab-ci.fooboozoo.fr;$/)}
        it { should contain_file('/etc/nginx/conf.d/gitlab-ci.conf').with_content(/^\s*server_tokens off;$/)}
        it { should contain_file('/etc/nginx/conf.d/gitlab-ci.conf').with_content(/^\s*root #{params_set[:ci_home]}\/gitlab-ci\/public;$/)}
        it { should contain_file('/etc/nginx/conf.d/gitlab-ci.conf').with_content(/^\s*proxy_read_timeout #{params_set[:gitlab_http_timeout]};$/)}
        it { should contain_file('/etc/nginx/conf.d/gitlab-ci.conf').with_content(/^\s*proxy_connect_timeout #{params_set[:gitlab_http_timeout]};$/)}
        ["hostname1", "hostname1 hostname2.example.com hostname3.example.org"].each do |domain_alias|
          context "with domain_alias => #{domain_alias}" do
            let(:params) { params_set.merge(:gitlab_domain_alias => domain_alias)} 
            it { should contain_file('/etc/nginx/conf.d/gitlab-ci.conf').with_content(/^\s*server_name gitlab-ci.fooboozoo.fr #{domain_alias};$/)}
          end
        end
        context 'with ssl' do
          let(:params) { params_set.merge(params_ssl) }
          it { should contain_file('/etc/nginx/conf.d/gitlab-ci.conf').with_content(/^\s*listen 443;$/)}
          it { should contain_file('/etc/nginx/conf.d/gitlab-ci.conf').with_content(/^\s*ssl_certificate               \/etc\/ssl\/certs\/ssl-cert-snakeoil.pem;$/)}
          it { should contain_file('/etc/nginx/conf.d/gitlab-ci.conf').with_content(/^\s*ssl_certificate_key           \/etc\/ssl\/private\/ssl-cert-snakeoil.key;$/)}
          it { should contain_file('/etc/nginx/conf.d/gitlab-ci.conf').with_content(/^\s*proxy_set_header   X-Forwarded-Ssl   on;$/)}
        end
        ["hostname1", "hostname1 hostname2.example.com hostname3.example.org"].each do |domain_alias|
          context "with ssl and domain_alias => #{domain_alias}" do
            let(:params) { params_set.merge(:gitlab_domain_alias => domain_alias)} 
            it { should contain_file('/etc/nginx/conf.d/gitlab-ci.conf').with_content(/^\s*server_name gitlab-ci.fooboozoo.fr #{domain_alias};$/)}
          end
        end
        context 'with ssl and custom certs' do
          let(:params) { params_set.merge(params_ssl.merge({:gitlab_ssl_cert => '/srv/ssl/gitlab.pem',:gitlab_ssl_key => '/srv/ssl/gitlab.key'})) }
            it { should contain_file('/etc/nginx/conf.d/gitlab-ci.conf').with_content(/^\s*ssl_certificate               \/srv\/ssl\/gitlab.pem;$/)}
            it { should contain_file('/etc/nginx/conf.d/gitlab-ci.conf').with_content(/^\s*ssl_certificate_key           \/srv\/ssl\/gitlab.key;$/)}
        end
      end # nginx config
      describe 'gitlab init' do
        it { should contain_file('/etc/init.d/gitlab_ci').with(
          :ensure  => 'file',
          :owner   => 'root',
          :group   => 'root',
          :mode    => '0755',
          :source  => "#{params_set[:ci_home]}/gitlab-ci/lib/support/init.d/gitlab_ci"
        )}
      end # gitlab init
      describe 'gitlab-ci directories' do
        ['gitlab-ci/tmp','gitlab-ci/tmp/pids','gitlab-ci/tmp/sockets','gitlab-ci/log','gitlab-ci/public'].each do |dir|
          it { should contain_file("#{params_set[:ci_home]}/#{dir}").with(
            :ensure => 'directory',
            :mode   => '0755'
          )}
        end
      end # gitlab directories
    end # specifics params
  end # gitlab::config
end # gitlab
