require 'spec_helper'

# Gitlab
describe 'gitlab' do

  ## Parameter set
  # a non-default common parameter set
  let :params_set do
    {
      :git_user               => 'gitlab',
      :git_home               => '/srv/gitlab',
      :gitlab_http_timeout    => '300',
      :webserver_service_name => 'nginx',
    }
  end

  # a non-default parameter set for SSL support
  let :params_ssl do
    {
      :gitlab_ssl             => true,
      :gitlab_ssl_self_signed => true
    }
  end

  # a non-default parameter set with non-default http port
  let :params_backup do
    {
      :gitlab_backup            => true,
      :gitlab_backup_time       => '7',
      :gitlab_backup_keep_time  => "#{ 60*60*24*30 }",
      :gitlab_backup_postscript => [
        'rsync -a --delete --max-delete=15 /home/git/gitlab/tmp/backups/ backup@backup01.esat:/queue/in/git01.esat',
      ],
    }
  end

  ### Gitlab::config
  describe 'gitlab::config' do
    context 'with default params' do
      describe 'nginx config' do
        it { is_expected.to contain_file('/etc/nginx/conf.d/gitlab.conf').with(
          :ensure => 'file',
          :owner  => 'root',
          :group  => 'root',
          :mode   => '0644',
          :notify => "Service[#{params_set[:webserver_service_name]}]"
        )}
        it { is_expected.to contain_file('/etc/nginx/conf.d/gitlab.conf').with_content(/^\s*server unix:\/home\/git\/gitlab\/tmp\/sockets\/gitlab.socket;$/)}
        it { is_expected.to contain_file('/etc/nginx/conf.d/gitlab.conf').with_content(/^\s*listen 80;$/)}
        it { is_expected.to contain_file('/etc/nginx/conf.d/gitlab.conf').with_content(/^\s*server_name gitlab.fooboozoo.fr;$/)}
        it { is_expected.to contain_file('/etc/nginx/conf.d/gitlab.conf').with_content(/^\s*server_tokens off;$/)}
        it { is_expected.to contain_file('/etc/nginx/conf.d/gitlab.conf').with_content(/^\s*root \/home\/git\/gitlab\/public;$/)}
        it { is_expected.to contain_file('/etc/nginx/conf.d/gitlab.conf').with_content(/^\s*proxy_read_timeout 60;$/)}
        it { is_expected.to contain_file('/etc/nginx/conf.d/gitlab.conf').with_content(/^\s*proxy_connect_timeout 60;$/)}
      end # nginx config
      describe 'gitlab init' do
        it { is_expected.to contain_file('/etc/default/gitlab').with(
          :ensure => 'file',
          :owner  => 'root',
          :group  => 'root',
          :mode   => '0644'
        )}
        it { is_expected.to contain_file('/etc/default/gitlab').with_content(/^\s*app_root="\/home\/git\/gitlab"$/)}
        it { is_expected.to contain_file('/etc/default/gitlab').with_content(/^\s*app_user="git"$/)}
      end # gitlab default
      describe 'gitlab init' do
        it { is_expected.to contain_file('/etc/init.d/gitlab').with(
          :ensure  => 'file',
          :owner   => 'root',
          :group   => 'root',
          :mode    => '0755',
          :require => 'File[/etc/default/gitlab]',
          :source  => '/home/git/gitlab/lib/support/init.d/gitlab'
        )}
      end # gitlab init
      describe 'gitlab logrotate' do
        it { is_expected.to contain_file("/etc/logrotate.d/gitlab").with(
          :ensure => 'file',
          :source => '/home/git/gitlab/lib/support/logrotate/gitlab',
          :owner  => 'root',
          :group  => 'root',
          :mode   => '0644'
        )}
      end # gitlab logrotate
      describe 'gitlab directories' do
        ['gitlab/tmp','gitlab/tmp/pids','gitlab/tmp/sockets','gitlab/log','gitlab/public'].each do |dir|
          it { is_expected.to contain_file("/home/git/#{dir}").with(
            :ensure => 'directory',
            :mode   => '0755'
          )}
        end

        ['gitlab/public/uploads'].each do |dir|
          it { is_expected.to contain_file("/home/git/#{dir}").with(
            :ensure => 'directory',
            :mode   => '0750'
          )}
        end
      end # gitlab directories

      describe 'no gitlab backup by default' do
        it { is_expected.not_to contain_file("/usr/local/sbin/gitlab-backup.sh") }
        it { is_expected.not_to contain_cron("gitlab backup ") }
      end # no gitlab backup by default

    end # default params
    context 'with specifics params' do
      let(:params) { params_set }
      describe 'nginx config' do
        it { is_expected.to contain_file('/etc/nginx/conf.d/gitlab.conf').with(
          :ensure => 'file',
          :owner  => 'root',
          :group  => 'root',
          :mode   => '0644'
        )}
        it { is_expected.to contain_file('/etc/nginx/conf.d/gitlab.conf').with_content(/^\s*server unix:#{params_set[:git_home]}\/gitlab\/tmp\/sockets\/gitlab.socket;$/)}
        it { is_expected.to contain_file('/etc/nginx/conf.d/gitlab.conf').with_content(/^\s*server_name gitlab.fooboozoo.fr;$/)}
        it { is_expected.to contain_file('/etc/nginx/conf.d/gitlab.conf').with_content(/^\s*server_tokens off;$/)}
        it { is_expected.to contain_file('/etc/nginx/conf.d/gitlab.conf').with_content(/^\s*root #{params_set[:git_home]}\/gitlab\/public;$/)}
        it { is_expected.to contain_file('/etc/nginx/conf.d/gitlab.conf').with_content(/^\s*proxy_read_timeout #{params_set[:gitlab_http_timeout]};$/)}
        it { is_expected.to contain_file('/etc/nginx/conf.d/gitlab.conf').with_content(/^\s*proxy_connect_timeout #{params_set[:gitlab_http_timeout]};$/)}
        ["hostname1", "hostname1 hostname2.example.com hostname3.example.org"].each do |domain_alias|
          context "with domain_alias => #{domain_alias}" do
            let(:params) { params_set.merge(:gitlab_domain_alias => domain_alias)}
            it { is_expected.to contain_file('/etc/nginx/conf.d/gitlab.conf').with_content(/^\s*server_name gitlab.fooboozoo.fr #{domain_alias};$/)}
          end
        end
        context 'with ssl' do
          let(:params) { params_set.merge(params_ssl) }
          it { is_expected.to contain_file('/etc/nginx/conf.d/gitlab.conf').with_content(/^\s*listen 443;$/)}
          it { is_expected.to contain_file('/etc/nginx/conf.d/gitlab.conf').with_content(/^\s*ssl_certificate               \/etc\/ssl\/certs\/ssl-cert-snakeoil.pem;$/)}
          it { is_expected.to contain_file('/etc/nginx/conf.d/gitlab.conf').with_content(/^\s*ssl_certificate_key           \/etc\/ssl\/private\/ssl-cert-snakeoil.key;$/)}
          it { is_expected.to contain_file('/etc/nginx/conf.d/gitlab.conf').with_content(/^\s*ssl_protocols                 TLSv1.2 TLSv1.1 TLSv1;$/)}
          it { is_expected.to contain_file('/etc/nginx/conf.d/gitlab.conf').with_content(/^\s*ssl_ciphers                   AES:HIGH:!aNULL:!RC4:!MD5:!ADH:!MDF;$/)}
          it { is_expected.to contain_file('/etc/nginx/conf.d/gitlab.conf').with_content(/^\s*proxy_set_header   X-Forwarded-Ssl   on;$/)}
        end
        ["hostname1", "hostname1 hostname2.example.com hostname3.example.org"].each do |domain_alias|
          context "with ssl and domain_alias => #{domain_alias}" do
            let(:params) { params_set.merge(:gitlab_domain_alias => domain_alias)}
            it { is_expected.to contain_file('/etc/nginx/conf.d/gitlab.conf').with_content(/^\s*server_name gitlab.fooboozoo.fr #{domain_alias};$/)}
          end
        end
        context 'with ssl and custom certs' do
          let(:params) { params_set.merge(params_ssl.merge({:gitlab_ssl_cert => '/srv/ssl/gitlab.pem',:gitlab_ssl_key => '/srv/ssl/gitlab.key'})) }
            it { is_expected.to contain_file('/etc/nginx/conf.d/gitlab.conf').with_content(/^\s*ssl_certificate               \/srv\/ssl\/gitlab.pem;$/)}
            it { is_expected.to contain_file('/etc/nginx/conf.d/gitlab.conf').with_content(/^\s*ssl_certificate_key           \/srv\/ssl\/gitlab.key;$/)}
        end
      end # nginx config

      context 'with backup' do
        let(:params) { params_set.merge(params_backup) }
          it { is_expected.to contain_file('/usr/local/sbin/backup-gitlab.sh').with_content(/^\s*rsync -a --delete --max-delete=15.*$/)}
          it { is_expected.to contain_file('/usr/local/sbin/backup-gitlab.sh').with_content(/^\s*cd #{params_set[:git_home]}\/gitlab$/)}
          it { is_expected.to contain_cron('gitlab backup').with(
            :command => '/usr/local/sbin/backup-gitlab.sh',
            :hour    => '7',
            :user    => params_set[:git_user]
          )}
          it { is_expected.to contain_file("#{params_set[:git_home]}/gitlab/config/gitlab.yml").with_content(/^\s*keep_time: 2592000$/)}
      end

      describe 'gitlab default' do
        it { is_expected.to contain_file('/etc/default/gitlab').with(
          :ensure => 'file',
          :owner  => 'root',
          :group  => 'root',
          :mode   => '0644'
        )}
        it { is_expected.to contain_file('/etc/default/gitlab').with_content(/^\s*app_root="#{params_set[:git_home]}\/gitlab"$/)}
        it { is_expected.to contain_file('/etc/default/gitlab').with_content(/^\s*app_user="#{params_set[:git_user]}"$/)}
      end # gitlab default
      describe 'gitlab init' do
        it { is_expected.to contain_file('/etc/init.d/gitlab').with(
          :ensure  => 'file',
          :owner   => 'root',
          :group   => 'root',
          :mode    => '0755',
          :require => 'File[/etc/default/gitlab]',
          :source  => "#{params_set[:git_home]}/gitlab/lib/support/init.d/gitlab"
        )}
      end # gitlab init
      describe 'gitlab logrotate' do
        it { is_expected.to contain_file("/etc/logrotate.d/gitlab").with(
          :ensure => 'file',
          :source => "#{params_set[:git_home]}/gitlab/lib/support/logrotate/gitlab",
          :owner  => 'root',
          :group  => 'root',
          :mode   => '0644'
        )}
      end # gitlab logrotate
      describe 'gitlab directories' do
        ['gitlab/tmp','gitlab/tmp/pids','gitlab/tmp/sockets','gitlab/log','gitlab/public','gitlab/public/uploads'].each do |dir|
          it { is_expected.to contain_file("#{params_set[:git_home]}/#{dir}").with(
            :ensure => 'directory',
            :mode   => '0755'
          )}
        end
      end # gitlab directories
    end # specifics params
  end # gitlab::config
end # gitlab
