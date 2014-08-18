require 'spec_helper'

# Gitlab
describe 'gitlab' do
  let(:facts) {{
    :osfamily       => 'Debian',
    :fqdn           => 'gitlab.fooboozoo.fr',
    :processorcount => '2',
    :sshrsakey      => 'AAAAB3NzaC1yc2EAAAA'
  }}

  ## Parameter set
  # a non-default common parameter set
  let :params_set do
    {
      :git_user                 => 'gitlab',
      :git_group                => 'gitgroup',
      :git_home                 => '/srv/gitlab',
      :git_email                => 'gitlab@fooboozoo.fr',
      :gitlab_repodir           => '/mnt/nas',
      :gitlab_redishost         => 'redis.fooboozoo.fr',
      :gitlab_redisport         => '9736',
      :gitlab_dbname            => 'gitlab_production',
      :gitlab_dbuser            => 'baltig',
      :gitlab_dbpwd             => 'Cie7cheewei<ngi3',
      :gitlab_dbhost            => 'sql.fooboozoo.fr',
      :gitlab_dbport            => '2345',
      :gitlab_relative_url_root => '/myfoobooforge',
      :gitlab_http_timeout      => '300',
      :gitlab_projects          => '42',
      :gitlab_username_change   => false,
      :gitlab_unicorn_port      => '8888',
      :gitlab_unicorn_worker    => '8',
      :gitlab_bundler_flags     => '--no-deployment',
      :gitlab_bundler_jobs      => '2',
      :exec_path                => '/opt/bw/bin:/bin:/usr/bin:/usr/sbin:/sbin:/usr/local/bin:/usr/local/sbin',
      :ldap_host                => 'ldap.fooboozoo.fr',
      :ldap_base                => 'dc=fooboozoo,dc=fr',
      :ldap_port                => '666',
      :ldap_uid                 => 'cn',
      :ldap_user_filter         => 'employeeType=developer',
      :ldap_method              => 'tls',
      :ldap_bind_dn             => 'uid=gitlab,o=bots,dc=fooboozoo,dc=fr',
      :ldap_bind_password       => 'aV!oo1ier5ahch;a',
      :ssh_port                 => '2223',
      :google_analytics_id      => 'UA-12345678-9',
      :company_logo_url         => 'http://fooboozoo.fr/logo.png',
      :company_link             => 'http://fooboozoo.fr',
      :company_name             => 'Fooboozoo',
      :use_exim                 => true
    }
  end

  # a non-default parameter set for SSL support
  let :params_ssl do
    {
      :gitlab_ssl             => true,
      :gitlab_ssl_self_signed => true
    }
  end

  # a non-default parameter set for SSL support with a non-default port
  let :params_ssl_non do
    {
      :gitlab_ssl             => true,
      :gitlab_ssl_self_signed => true,
      :gitlab_ssl_port        => '4443'
    }
  end

  ## Gitlab::install
  describe 'gitlab::install' do
    context 'with default params' do
      describe 'gitlab-shell' do
        it { should contain_file('/home/git/gitlab-shell/config.yml').with(:ensure => 'file', :mode => '0644', :group => 'git', :owner => 'git')}
        it { should contain_file('/home/git/gitlab-shell/config.yml').with_content(/^\s*user: git$/)}
        it { should contain_file('/home/git/gitlab-shell/config.yml').with_content(/^\s*gitlab_url: "http:\/\/gitlab.fooboozoo.fr\/"$/)}
        it { should contain_file('/home/git/gitlab-shell/config.yml').with_content(/^\s*self_signed_cert: false$/)}
        it { should contain_file('/home/git/gitlab-shell/config.yml').with_content(/^\s*repos_path: "\/home\/git\/repositories"$/)}
        it { should contain_file('/home/git/gitlab-shell/config.yml').with_content(/^\s*auth_file: "\/home\/git\/.ssh\/authorized_keys"$/)}
        it { should contain_file('/home/git/gitlab-shell/config.yml').with_content(/^\s*host: 127.0.0.1$/)}
        it { should contain_file('/home/git/gitlab-shell/config.yml').with_content(/^\s*port: 6379$/)}
        it { should contain_exec('install gitlab-shell').with(
          :user     => 'git',
          :path     => '/home/git/.rbenv/shims:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
          :command  => 'ruby /home/git/gitlab-shell/bin/install',
          :cwd      => '/home/git',
          :creates  => '/home/git/repositories',
          :require  => 'File[/home/git/gitlab-shell/config.yml]'
        )}
      end # gitlab-shell
      describe 'gitlab config' do
        it { should contain_file('/home/git/gitlab/config/gitlab.yml').with(:ensure => 'file',:owner => 'git',:group => 'git')}
        it { should contain_file('/home/git/gitlab/config/gitlab.yml').with_content(/^\s*host: gitlab.fooboozoo.fr$/)}
        context 'with ssl' do
          let(:params) {{ :gitlab_ssl => true }}
          it { should contain_file('/home/git/gitlab/config/gitlab.yml').with_content(/^\s*port: 443$/)}
          it { should contain_file('/home/git/gitlab/config/gitlab.yml').with_content(/^\s*https: true$/)}
        end
        it { should contain_file('/home/git/gitlab/config/gitlab.yml').with_content(/^\s*port: 80$/)}
        it { should contain_file('/home/git/gitlab/config/gitlab.yml').with_content(/^\s*https: false$/)}
        it { should_not contain_file('/home/git/gitlab/config/gitlab.yml').with_content(/^\s*relative_url_root: \/myfoobooforge$/)}
        it { should_not contain_file('/home/git/gitlab/config/application.rb')}
        it { should contain_file('/home/git/gitlab/config/gitlab.yml').with_content(/^\s*email_from: git@someserver.net$/)}
        it { should contain_file('/home/git/gitlab/config/gitlab.yml').with_content(/^\s*default_projects_limit: 10$/)}
        it { should contain_file('/home/git/gitlab/config/gitlab.yml').with_content(/^\s*username_changing_enabled: true$/)}
        it { should contain_file('/home/git/gitlab/config/gitlab.yml').with_content(/^\s*host: 'ldap.domain.com'$/)}
        it { should contain_file('/home/git/gitlab/config/gitlab.yml').with_content(/^\s*base: 'dc=domain,dc=com'$/)}
        it { should contain_file('/home/git/gitlab/config/gitlab.yml').with_content(/^\s*port: 636$/)}
        it { should contain_file('/home/git/gitlab/config/gitlab.yml').with_content(/^\s*uid: 'uid'$/)}
        it { should contain_file('/home/git/gitlab/config/gitlab.yml').with_content(/^\s*user_filter: ''$/)}
        it { should contain_file('/home/git/gitlab/config/gitlab.yml').with_content(/^\s*method: 'ssl'$/)}
        it { should contain_file('/home/git/gitlab/config/gitlab.yml').with_content(/^\s*path: \/home\/git\/gitlab-satellites\/$/)}
        it { should contain_file('/home/git/gitlab/config/gitlab.yml').with_content(/^\s*repos_path: \/home\/git\/repositories\/$/)}
        it { should contain_file('/home/git/gitlab/config/gitlab.yml').with_content(/^\s*hooks_path: \/home\/git\/gitlab-shell\/hooks\/$/)}
        it { should contain_file('/home/git/gitlab/config/gitlab.yml').with_content(/^\s*ssh_port: 22$/)}
        it { should contain_file('/home/git/gitlab/config/gitlab.yml').with_content(/^\s*# google_analytics_id: '_your_tracking_id'$/)}
        it { should contain_file('/home/git/gitlab/config/gitlab.yml').with_content(/^\s*# sign_in_text: \|\n\s*#   !\[Company Logo\]\(http:\/\/www.companydomain.com\/logo.png\)\n\s*#   \[Learn more about CompanyName\]\(http:\/\/www.companydomain.com\/\)$/)}
      end # gitlab config
      describe 'rack_attack config' do
        it { should contain_file('/home/git/gitlab/config/initializers/rack_attack.rb').with(
          :ensure => 'file',
          :source => '/home/git/gitlab/config/initializers/rack_attack.rb.example'
        )}
      end # rack_attack config
      describe 'install gitlab' do
        it { should contain_exec('install gitlab').with(
          :user    => 'git',
          :path     => '/home/git/.rbenv/shims:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
          :command => "bundle install --without development aws test postgres --deployment",
          :unless  => 'bundle check',
          :cwd     => '/home/git/gitlab',
          :timeout => 0,
          :require => ['Gitlab::Config::Database[gitlab]',
                        'Gitlab::Config::Unicorn[gitlab]',
                        'File[/home/git/gitlab/config/gitlab.yml]',
                        'Gitlab::Config::Resque[gitlab]'],
          :notify  => 'Exec[run migrations]'
        )}
        it { should contain_exec('run migrations').with(
          :command     => 'bundle exec rake db:migrate RAILS_ENV=production',
          :cwd         => '/home/git/gitlab',
          :refreshonly => 'true',
          :notify      => 'Exec[precompile assets]'
        )}
        context 'postgresql' do
          let(:params) {{ :gitlab_dbtype => 'pgsql' }}
          it { should contain_exec('install gitlab').with(
            :user    => 'git',
            :path     => '/home/git/.rbenv/shims:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
            :command => "bundle install --without development aws test mysql --deployment",
            :unless  => 'bundle check',
            :cwd     => '/home/git/gitlab',
            :timeout => 0,
            :require => ['Gitlab::Config::Database[gitlab]',
                        'Gitlab::Config::Unicorn[gitlab]',
                        'File[/home/git/gitlab/config/gitlab.yml]',
                        'Gitlab::Config::Resque[gitlab]']
          )}
        end # pgsql
      end # install gitlab
      describe 'setup gitlab database' do
        it { should contain_exec('setup gitlab database').with(
          :user    => 'git',
          :path    => '/home/git/.rbenv/shims:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
          :command => '/usr/bin/yes yes | bundle exec rake gitlab:setup RAILS_ENV=production',
          :cwd     => '/home/git/gitlab',
          :creates => '/home/git/.gitlab_setup_done',
          :before  => 'Exec[run migrations]',
          :require => 'Exec[install gitlab]',
          :notify  => 'Exec[precompile assets]'
        )}
        it { should contain_exec('precompile assets').with(
          :command     => 'bundle exec rake assets:clean assets:precompile cache:clear RAILS_ENV=production',
          :cwd         => '/home/git/gitlab',
          :refreshonly => 'true'
        )}
        it { should contain_file("/home/git/.gitlab_setup_done").with(
          :ensure   => 'present',
          :owner    => 'root',
          :group    => 'root',
          :require  => 'Exec[setup gitlab database]'
        )}
      end # setup gitlab database
    end # defaults params
    context 'with specifics params' do
      let(:params) { params_set }
      describe 'gitlab-shell' do
        it { should contain_file("#{params_set[:git_home]}/gitlab-shell/config.yml").with(:ensure => 'file',:mode => '0644',:group => 'gitgroup',:owner => 'gitlab')}
        it { should contain_file("#{params_set[:git_home]}/gitlab-shell/config.yml").with_content(/^\s*user: #{params_set[:git_user]}$/)}
        it { should contain_file("#{params_set[:git_home]}/gitlab-shell/config.yml").with_content(/^\s*gitlab_url: "http:\/\/gitlab.fooboozoo.fr#{params_set[:gitlab_relative_url_root]}"$/)}
        context 'with ssl' do
          let(:params) { params_set.merge(params_ssl) }
          it { should contain_file("#{params_set[:git_home]}/gitlab-shell/config.yml").with_content(/^\s*gitlab_url: "https:\/\/gitlab.fooboozoo.fr#{params_set[:gitlab_relative_url_root]}"$/)}
        end
        it { should contain_file("#{params_set[:git_home]}/gitlab-shell/config.yml").with_content(/^\s*self_signed_cert: false$/)}
        context 'with self signed ssl cert' do
          let(:params) { params_set.merge(params_ssl) }
          it { should contain_file("#{params_set[:git_home]}/gitlab-shell/config.yml").with_content(/^\s*self_signed_cert: true$/)}
        end
        it { should contain_file("#{params_set[:git_home]}/gitlab-shell/config.yml").with_content(/^\s*repos_path: "#{params_set[:gitlab_repodir]}\/repositories"$/)}
        it { should contain_file("#{params_set[:git_home]}/gitlab-shell/config.yml").with_content(/^\s*auth_file: "#{params_set[:git_home]}\/.ssh\/authorized_keys"$/)}
        it { should contain_file("#{params_set[:git_home]}/gitlab-shell/config.yml").with_content(/^\s*host: #{params_set[:gitlab_redishost]}$/)}
        it { should contain_file("#{params_set[:git_home]}/gitlab-shell/config.yml").with_content(/^\s*port: #{params_set[:gitlab_redisport]}$/)}
        it { should contain_exec('install gitlab-shell').with(
          :user     => params_set[:git_user],
          :path     => params_set[:exec_path],
          :command  => "ruby #{params_set[:git_home]}/gitlab-shell/bin/install",
          :cwd      => params_set[:git_home],
          :creates  => "#{params_set[:gitlab_repodir]}/repositories",
          :require  => "File[#{params_set[:git_home]}/gitlab-shell/config.yml]"
        )}
      end # gitlab-shell

      describe 'gitlab config' do
        it { should contain_file("#{params_set[:git_home]}/gitlab/config/gitlab.yml").with(:ensure => 'file',:owner => params_set[:git_user],:group => params_set[:git_group])}
        it { should contain_file("#{params_set[:git_home]}/gitlab/config/gitlab.yml").with_content(/^\s*host: gitlab.fooboozoo.fr$/)}
        it { should contain_file("#{params_set[:git_home]}/gitlab/config/gitlab.yml").with_content(/^\s*port: 80$/)}
        it { should contain_file("#{params_set[:git_home]}/gitlab/config/gitlab.yml").with_content(/^\s*https: false$/)}
        context 'with ssl' do
          let(:params) { params_set.merge(params_ssl) }
          it { should contain_file("#{params_set[:git_home]}/gitlab/config/gitlab.yml").with_content(/^\s*port: 443$/)}
          it { should contain_file("#{params_set[:git_home]}/gitlab/config/gitlab.yml").with_content(/^\s*https: true$/)}
        end
        context 'with non-default http ports' do
          let(:params) { params_set.merge!(:gitlab_http_port => '81') }
          it { should contain_file("#{params_set[:git_home]}/gitlab/config/gitlab.yml").with_content(/^\s*port: 81$/)}
          it { should contain_file("#{params_set[:git_home]}/gitlab/config/gitlab.yml").with_content(/^\s*https: false$/)}
          context 'with non-default https ports' do
            let(:params) { params_set.merge!(:gitlab_ssl => true, :gitlab_ssl_self_signed => true, :gitlab_ssl_port => '444') }
            it { should contain_file("#{params_set[:git_home]}/gitlab/config/gitlab.yml").with_content(/^\s*port: 444$/)}
            it { should contain_file("#{params_set[:git_home]}/gitlab/config/gitlab.yml").with_content(/^\s*https: true$/)}
          end
        end
        it { should contain_file("#{params_set[:git_home]}/gitlab/config/gitlab.yml").with_content(/^\s*relative_url_root: #{params_set[:gitlab_relative_url_root]}$/)}
        it { should contain_file("#{params_set[:git_home]}/gitlab/config/application.rb").with_content(/^\s*config.relative_url_root = "#{params_set[:gitlab_relative_url_root]}"$/)}
        it { should contain_file("#{params_set[:git_home]}/gitlab/config/gitlab.yml").with_content(/^\s*email_from: #{params_set[:git_email]}$/)}
        it { should contain_file("#{params_set[:git_home]}/gitlab/config/gitlab.yml").with_content(/^\s*default_projects_limit: #{params_set[:gitlab_projects]}$/)}
        it { should contain_file("#{params_set[:git_home]}/gitlab/config/gitlab.yml").with_content(/^\s*username_changing_enabled: #{params_set[:gitlab_username_change]}$/)}
        it { should contain_file("#{params_set[:git_home]}/gitlab/config/gitlab.yml").with_content(/^\s*host: '#{params_set[:ldap_host]}'$/)}
        it { should contain_file("#{params_set[:git_home]}/gitlab/config/gitlab.yml").with_content(/^\s*base: '#{params_set[:ldap_base]}'$/)}
        it { should contain_file("#{params_set[:git_home]}/gitlab/config/gitlab.yml").with_content(/^\s*port: #{params_set[:ldap_port]}$/)}
        it { should contain_file("#{params_set[:git_home]}/gitlab/config/gitlab.yml").with_content(/^\s*uid: '#{params_set[:ldap_uid]}'$/)}
        it { should contain_file("#{params_set[:git_home]}/gitlab/config/gitlab.yml").with_content(/^\s*user_filter: '#{params_set[:ldap_user_filter]}'$/)}
        it { should contain_file("#{params_set[:git_home]}/gitlab/config/gitlab.yml").with_content(/^\s*method: '#{params_set[:ldap_method]}'$/)}
        it { should contain_file("#{params_set[:git_home]}/gitlab/config/gitlab.yml").with_content(/^\s*bind_dn: '#{params_set[:ldap_bind_dn]}'$/)}
        it { should contain_file("#{params_set[:git_home]}/gitlab/config/gitlab.yml").with_content(/^\s*password: '#{params_set[:ldap_bind_password]}'$/)}
        it { should contain_file("#{params_set[:git_home]}/gitlab/config/gitlab.yml").with_content(/^\s*path: #{params_set[:git_home]}\/gitlab-satellites\/$/)}
        it { should contain_file("#{params_set[:git_home]}/gitlab/config/gitlab.yml").with_content(/^\s*repos_path: #{params_set[:gitlab_repodir]}\/repositories\/$/)}
        it { should contain_file("#{params_set[:git_home]}/gitlab/config/gitlab.yml").with_content(/^\s*hooks_path: #{params_set[:git_home]}\/gitlab-shell\/hooks\/$/)}
        it { should contain_file("#{params_set[:git_home]}/gitlab/config/gitlab.yml").with_content(/^\s*ssh_port: #{params_set[:ssh_port]}$/)}
        it { should contain_file("#{params_set[:git_home]}/gitlab/config/gitlab.yml").with_content(/^\s*google_analytics_id: #{params_set[:google_analytics_id]}$/)}
        it { should contain_file("#{params_set[:git_home]}/gitlab/config/gitlab.yml").with_content(/^\s*sign_in_text: \|\n\s*!\[Company Logo\]\(#{params_set[:company_logo_url]}\)\n\s*\[Learn more about #{params_set[:company_name]}\]\(#{params_set[:company_link]}\)$/)}
        it { should contain_file("#{params_set[:git_home]}/gitlab/config/application.rb").with_content(/^\s*#Fix for compatibility issue with exim as explained at https:\/\/github.com\/gitlabhq\/gitlabhq\/issues\/4866\s*config.action_mailer.sendmail_settings = \{ :arguments => "-i" \}$/)}
      end # gitlab config
      describe 'rack_attack config' do
        it { should contain_file("#{params_set[:git_home]}/gitlab/config/initializers/rack_attack.rb").with(
          :ensure => 'file',
          :source => "#{params_set[:git_home]}/gitlab/config/initializers/rack_attack.rb.example"
        )}
      end # rack_attack config
      describe 'install gitlab' do
        it { should contain_exec('install gitlab').with(
          :user    => params_set[:git_user],
          :path    => params_set[:exec_path],
          :command => "bundle install -j#{params_set[:gitlab_bundler_jobs]} --without development aws test postgres #{params_set[:gitlab_bundler_flags]}",
          :unless  => 'bundle check',
          :cwd     => "#{params_set[:git_home]}/gitlab",
          :timeout => 0,
          :require => ['Gitlab::Config::Database[gitlab]',
                       'Gitlab::Config::Unicorn[gitlab]',
                       "File[#{params_set[:git_home]}/gitlab/config/gitlab.yml]",
                       'Gitlab::Config::Resque[gitlab]']
        )}
        context 'postgresql' do
          let(:params) { params_set.merge({ :gitlab_dbtype => 'pgsql' }) }
          it { should contain_exec('install gitlab').with(
            :user    => params_set[:git_user],
            :path    => params_set[:exec_path],
            :command => "bundle install -j#{params_set[:gitlab_bundler_jobs]} --without development aws test mysql #{params_set[:gitlab_bundler_flags]}",
            :unless  => 'bundle check',
            :cwd     => "#{params_set[:git_home]}/gitlab",
            :timeout => 0,
            :require => ['Gitlab::Config::Database[gitlab]',
                       'Gitlab::Config::Unicorn[gitlab]',
                       "File[#{params_set[:git_home]}/gitlab/config/gitlab.yml]",
                       'Gitlab::Config::Resque[gitlab]']
          )}
        end # pgsql
      end # install gitlab
      describe 'setup gitlab database' do
        it { should contain_exec('setup gitlab database').with(
          :user    => params_set[:git_user],
          :path    => params_set[:exec_path],
          :command => '/usr/bin/yes yes | bundle exec rake gitlab:setup RAILS_ENV=production',
          :cwd     => "#{params_set[:git_home]}/gitlab",
          :creates => "#{params_set[:git_home]}/.gitlab_setup_done",
          :require => 'Exec[install gitlab]'
        )}
        it { should contain_file("#{params_set[:git_home]}/.gitlab_setup_done").with(
          :ensure   => 'present',
          :owner    => 'root',
          :group    => 'root',
          :require  => 'Exec[setup gitlab database]'
        )}
      end # setup gitlab database
    end # with params
  end # gitlab::install
end # gitlab
