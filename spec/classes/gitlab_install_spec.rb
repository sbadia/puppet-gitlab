require 'spec_helper'

# Gitlab
describe 'gitlab' do
  let(:facts) {{
    :osfamily  => 'Debian',
    :fqdn      => 'gitlab.fooboozoo.fr',
    :sshrsakey => 'AAAAB3NzaC1yc2EAAAA'
  }}

  ## Parameter set
  # a non-default common parameter set
  let :params_set do
    {
      :git_user                 => 'gitlab',
      :git_home                 => '/srv/gitlab',
      :git_comment              => 'Labfooboozoo',
      :git_email                => 'gitlab@fooboozoo.fr',
      :gitlab_sources           => 'https://github.com/gitlabhq/gitlabhq',
      :gitlab_branch            => '4-2-stable',
      :gitlabshell_sources      => 'https://github.com/gitlabhq/gitlab-shell',
      :gitlabshell_branch       => 'v1.2.3',
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
      :exec_path                => '/opt/bw/bin:/bin:/usr/bin:/usr/sbin:/sbin:/usr/local/bin:/usr/local/sbin',
      :ldap_host                => 'ldap.fooboozoo.fr',
      :ldap_base                => 'dc=fooboozoo,dc=fr',
      :ldap_port                => '666',
      :ldap_uid                 => 'cn',
      :ldap_method              => 'tls',
      :ldap_bind_dn             => 'uid=gitlab,o=bots,dc=fooboozoo,dc=fr',
      :ldap_bind_password       => 'aV!oo1ier5ahch;a'
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
        it { should contain_file('/home/git/gitlab-shell/config.yml').with_content(/user: git/)}
        it { should contain_file('/home/git/gitlab-shell/config.yml').with_content(/gitlab_url: "http:\/\/gitlab.fooboozoo.fr\/"/)}
        it { should contain_file('/home/git/gitlab-shell/config.yml').with_content(/self_signed_cert: false/)}
        it { should contain_file('/home/git/gitlab-shell/config.yml').with_content(/repos_path: "\/home\/git\/repositories"/)}
        it { should contain_file('/home/git/gitlab-shell/config.yml').with_content(/auth_file: "\/home\/git\/.ssh\/authorized_keys"/)}
        it { should contain_file('/home/git/gitlab-shell/config.yml').with_content(/host: 127.0.0.1/)}
        it { should contain_file('/home/git/gitlab-shell/config.yml').with_content(/port: 6379/)}
        it { should contain_exec('install gitlab-shell').with(
          :user     => 'git',
          :path     => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
          :command  => 'ruby /home/git/gitlab-shell/bin/install',
          :cwd      => '/home/git',
          :creates  => '/home/git/repositories',
          :require  => 'File[/home/git/gitlab-shell/config.yml]'
        )}
      end # gitlab-shell
      describe 'database config' do
        it { should contain_file('/home/git/gitlab/config/database.yml').with(:ensure => 'file',:owner => 'git',:group => 'git')}
        it { should contain_file('/home/git/gitlab/config/database.yml').with_content(/adapter: mysql2/)}
        it { should contain_file('/home/git/gitlab/config/database.yml').with_content(/encoding: utf8/)}
        it { should contain_file('/home/git/gitlab/config/database.yml').with_content(/database: gitlab_db/)}
        it { should contain_file('/home/git/gitlab/config/database.yml').with_content(/username: gitlab_user/)}
        it { should contain_file('/home/git/gitlab/config/database.yml').with_content(/password: changeme/)}
        it { should contain_file('/home/git/gitlab/config/database.yml').with_content(/host: localhost/)}
        context 'postgresql' do
          let(:params) {{ :gitlab_dbtype => 'pgsql' }}
          it { should contain_file('/home/git/gitlab/config/database.yml').with_content(/adapter: postgresql/)}
          it { should contain_file('/home/git/gitlab/config/database.yml').with_content(/encoding: unicode/)}
          it { should contain_file('/home/git/gitlab/config/database.yml').with_content(/database: gitlab_db/)}
          it { should contain_file('/home/git/gitlab/config/database.yml').with_content(/username: gitlab_user/)}
          it { should contain_file('/home/git/gitlab/config/database.yml').with_content(/password: changeme/)}
          it { should contain_file('/home/git/gitlab/config/database.yml').with_content(/host: localhost/)}
          it { should contain_file('/home/git/gitlab/config/database.yml').with_content(/port: 5432/)}
        end # pgsql
      end # database config
      describe 'unicorn config' do
        it { should contain_file('/home/git/gitlab/config/unicorn.rb').with(:ensure => 'file',:owner => 'git',:group => 'git')}
        it { should contain_file('/home/git/gitlab/config/unicorn.rb').with_content(/worker_processes 2/)}
        it { should contain_file('/home/git/gitlab/config/unicorn.rb').with_content(/working_directory "\/home\/git\/gitlab"/)}
        it { should contain_file('/home/git/gitlab/config/unicorn.rb').with_content(/listen "127.0.0.1:8080"/)}
        it { should contain_file('/home/git/gitlab/config/unicorn.rb').with_content(/listen "\/home\/git\/gitlab\/tmp\/sockets\/gitlab.socket"/)}
        it { should contain_file('/home/git/gitlab/config/unicorn.rb').with_content(/timeout 60/)}
        it { should contain_file('/home/git/gitlab/config/unicorn.rb').with_content(/pid "\/home\/git\/gitlab\/tmp\/pids\/unicorn.pid"/)}
        it { should contain_file('/home/git/gitlab/config/unicorn.rb').with_content(/stderr_path "\/home\/git\/gitlab\/log\/unicorn.stderr.log"/)}
        it { should contain_file('/home/git/gitlab/config/unicorn.rb').with_content(/stdout_path "\/home\/git\/gitlab\/log\/unicorn.stdout.log"/)}
      end # unicorn config
      describe 'gitlab config' do
        it { should contain_file('/home/git/gitlab/config/gitlab.yml').with(:ensure => 'file',:owner => 'git',:group => 'git')}
        it { should contain_file('/home/git/gitlab/config/gitlab.yml').with_content(/host: gitlab.fooboozoo.fr/)}
        context 'with ssl' do
          let(:params) {{ :gitlab_ssl => true }}
          it { should contain_file('/home/git/gitlab/config/gitlab.yml').with_content(/port: 443/)}
          it { should contain_file('/home/git/gitlab/config/gitlab.yml').with_content(/https: true/)}
        end
        it { should contain_file('/home/git/gitlab/config/gitlab.yml').with_content(/port: 80/)}
        it { should contain_file('/home/git/gitlab/config/gitlab.yml').with_content(/https: false/)}
        it { should contain_file('/home/git/gitlab/config/gitlab.yml').with_content(/relative_url_root: \//)}
        it { should contain_file('/home/git/gitlab/config/gitlab.yml').with_content(/email_from: git@someserver.net/)}
        it { should contain_file('/home/git/gitlab/config/gitlab.yml').with_content(/default_projects_limit: 10/)}
        it { should contain_file('/home/git/gitlab/config/gitlab.yml').with_content(/username_changing_enabled: true/)}
        it { should contain_file('/home/git/gitlab/config/gitlab.yml').with_content(/host: 'ldap.domain.com'/)}
        it { should contain_file('/home/git/gitlab/config/gitlab.yml').with_content(/base: 'dc=domain,dc=com'/)}
        it { should contain_file('/home/git/gitlab/config/gitlab.yml').with_content(/port: 636/)}
        it { should contain_file('/home/git/gitlab/config/gitlab.yml').with_content(/uid: 'uid'/)}
        it { should contain_file('/home/git/gitlab/config/gitlab.yml').with_content(/method: 'ssl'/)}
        it { should contain_file('/home/git/gitlab/config/gitlab.yml').with_content(/path: \/home\/git\/gitlab-satellites\//)}
        it { should contain_file('/home/git/gitlab/config/gitlab.yml').with_content(/repos_path: \/home\/git\/repositories\//)}
        it { should contain_file('/home/git/gitlab/config/gitlab.yml').with_content(/hooks_path: \/home\/git\/gitlab-shell\/hooks\//)}
      end # gitlab config
      describe 'resque config' do
        it { should contain_file('/home/git/gitlab/config/resque.yml').with(:ensure => 'file',:owner => 'git',:group => 'git')}
        it { should contain_file('/home/git/gitlab/config/resque.yml').with_content(/production: redis:\/\/127.0.0.1:6379/)}
      end # resque config
      describe 'rack_attack config' do
        it { should contain_file('/home/git/gitlab/config/initializers/rack_attack.rb').with(
          :ensure => 'file',
          :source => '/home/git/gitlab/config/initializers/rack_attack.rb.example'
        )}
      end # rack_attack config
      describe 'install gitlab' do
        it { should contain_exec('install gitlab').with(
          :user    => 'git',
          :path    => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
          :command => 'bundle install --without development aws test postgres --deployment',
          :unless  => 'bundle check',
          :cwd     => '/home/git/gitlab',
          :timeout => 0,
          :require => ['File[/home/git/gitlab/config/database.yml]',
                        'File[/home/git/gitlab/config/unicorn.rb]',
                        'File[/home/git/gitlab/config/gitlab.yml]',
                        'File[/home/git/gitlab/config/resque.yml]']
        )}
        context 'postgresql' do
          let(:params) {{ :gitlab_dbtype => 'pgsql' }}
          it { should contain_exec('install gitlab').with(
            :user    => 'git',
            :path    => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
            :command => 'bundle install --without development aws test mysql --deployment',
            :unless  => 'bundle check',
            :cwd     => '/home/git/gitlab',
            :timeout => 0,
            :require => ['File[/home/git/gitlab/config/database.yml]',
                          'File[/home/git/gitlab/config/unicorn.rb]',
                          'File[/home/git/gitlab/config/gitlab.yml]',
                          'File[/home/git/gitlab/config/resque.yml]']
          )}
        end # pgsql
      end # install gitlab
      describe 'setup gitlab database' do
        it { should contain_exec('setup gitlab database').with(
          :user    => 'git',
          :path    => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
          :command => '/usr/bin/yes yes | bundle exec rake gitlab:setup RAILS_ENV=production',
          :cwd     => '/home/git/gitlab',
          :creates => '/home/git/.gitlab_setup_done',
          :require => 'Exec[install gitlab]'
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
        it { should contain_file("#{params_set[:git_home]}/gitlab-shell/config.yml").with(:ensure => 'file',:mode => '0644',:group => 'gitlab',:owner => 'gitlab')}
        it { should contain_file("#{params_set[:git_home]}/gitlab-shell/config.yml").with_content(/user: #{params_set[:git_user]}/)}
        it { should contain_file("#{params_set[:git_home]}/gitlab-shell/config.yml").with_content(/gitlab_url: "http:\/\/gitlab.fooboozoo.fr\/"/)}
        context 'with ssl' do
          let(:params) { params_set.merge(params_ssl) }
          it { should contain_file("#{params_set[:git_home]}/gitlab-shell/config.yml").with_content(/gitlab_url: "https:\/\/gitlab.fooboozoo.fr\/"/)}
        end
        it { should contain_file("#{params_set[:git_home]}/gitlab-shell/config.yml").with_content(/self_signed_cert: false/)}
        context 'with self signed ssl cert' do
          let(:params) { params_set.merge(params_ssl) }
          it { should contain_file("#{params_set[:git_home]}/gitlab-shell/config.yml").with_content(/self_signed_cert: true/)}
        end
        it { should contain_file("#{params_set[:git_home]}/gitlab-shell/config.yml").with_content(/repos_path: "#{params_set[:gitlab_repodir]}\/repositories"/)}
        it { should contain_file("#{params_set[:git_home]}/gitlab-shell/config.yml").with_content(/auth_file: "#{params_set[:git_home]}\/.ssh\/authorized_keys"/)}
        it { should contain_file("#{params_set[:git_home]}/gitlab-shell/config.yml").with_content(/host: #{params_set[:gitlab_redishost]}/)}
        it { should contain_file("#{params_set[:git_home]}/gitlab-shell/config.yml").with_content(/port: #{params_set[:gitlab_redisport]}/)}
        it { should contain_exec('install gitlab-shell').with(
          :user     => params_set[:git_user],
          :path     => params_set[:exec_path],
          :command  => "ruby #{params_set[:git_home]}/gitlab-shell/bin/install",
          :cwd      => params_set[:git_home],
          :creates  => "#{params_set[:gitlab_repodir]}/repositories",
          :require  => "File[#{params_set[:git_home]}/gitlab-shell/config.yml]"
        )}
      end # gitlab-shell

      describe 'database config' do
        it { should contain_file("#{params_set[:git_home]}/gitlab/config/database.yml").with(
          :ensure => 'file',
          :owner  => params_set[:git_user],
          :group  => params_set[:git_user]
        )}
        it { should contain_file("#{params_set[:git_home]}/gitlab/config/database.yml").with_content(/adapter: mysql2/)}
        it { should contain_file("#{params_set[:git_home]}/gitlab/config/database.yml").with_content(/encoding: utf8/)}
        it { should contain_file("#{params_set[:git_home]}/gitlab/config/database.yml").with_content(/database: #{params_set[:gitlab_dbname]}/)}
        it { should contain_file("#{params_set[:git_home]}/gitlab/config/database.yml").with_content(/username: #{params_set[:gitlab_dbuser]}/)}
        it { should contain_file("#{params_set[:git_home]}/gitlab/config/database.yml").with_content(/password: #{params_set[:gitlab_dbpwd]}/)}
        it { should contain_file("#{params_set[:git_home]}/gitlab/config/database.yml").with_content(/host: #{params_set[:gitlab_dbhost]}/)}
        context 'postgresql' do
          let(:params) { params_set.merge({ :gitlab_dbtype => 'pgsql' }) }
          it { should contain_file("#{params_set[:git_home]}/gitlab/config/database.yml").with_content(/adapter: postgresql/)}
          it { should contain_file("#{params_set[:git_home]}/gitlab/config/database.yml").with_content(/encoding: unicode/)}
          it { should contain_file("#{params_set[:git_home]}/gitlab/config/database.yml").with_content(/database: #{params_set[:gitlab_dbname]}/)}
          it { should contain_file("#{params_set[:git_home]}/gitlab/config/database.yml").with_content(/username: #{params_set[:gitlab_dbuser]}/)}
          it { should contain_file("#{params_set[:git_home]}/gitlab/config/database.yml").with_content(/password: #{params_set[:gitlab_dbpwd]}/)}
          it { should contain_file("#{params_set[:git_home]}/gitlab/config/database.yml").with_content(/host: #{params_set[:gitlab_dbhost]}/)}
          it { should contain_file("#{params_set[:git_home]}/gitlab/config/database.yml").with_content(/port: #{params_set[:gitlab_dbport]}/)}
        end # pgsql
      end # database config
      describe 'unicorn config' do
        it { should contain_file("#{params_set[:git_home]}/gitlab/config/unicorn.rb").with(:ensure => 'file',:owner => params_set[:git_user],:group => params_set[:git_user])}
        it { should contain_file("#{params_set[:git_home]}/gitlab/config/unicorn.rb").with_content(/worker_processes #{params_set[:gitlab_unicorn_worker]}/)}
        it { should contain_file("#{params_set[:git_home]}/gitlab/config/unicorn.rb").with_content(/working_directory "#{params_set[:git_home]}\/gitlab"/)}

        it { should contain_file("#{params_set[:git_home]}/gitlab/config/unicorn.rb").with_content(/listen "127.0.0.1:#{params_set[:gitlab_unicorn_port]}"/)}
        it { should contain_file("#{params_set[:git_home]}/gitlab/config/unicorn.rb").with_content(/timeout #{params_set[:gitlab_http_timeout]}/)}
        it { should contain_file("#{params_set[:git_home]}/gitlab/config/unicorn.rb").with_content(/listen "#{params_set[:git_home]}\/gitlab\/tmp\/sockets\/gitlab.socket"/)}
        it { should contain_file("#{params_set[:git_home]}/gitlab/config/unicorn.rb").with_content(/pid "#{params_set[:git_home]}\/gitlab\/tmp\/pids\/unicorn.pid"/)}
        it { should contain_file("#{params_set[:git_home]}/gitlab/config/unicorn.rb").with_content(/stderr_path "#{params_set[:git_home]}\/gitlab\/log\/unicorn.stderr.log"/)}
        it { should contain_file("#{params_set[:git_home]}/gitlab/config/unicorn.rb").with_content(/stdout_path "#{params_set[:git_home]}\/gitlab\/log\/unicorn.stdout.log"/)}
      end # unicorn config
      describe 'gitlab config' do
        it { should contain_file("#{params_set[:git_home]}/gitlab/config/gitlab.yml").with(:ensure => 'file',:owner => params_set[:git_user],:group => params_set[:git_user])}
        it { should contain_file("#{params_set[:git_home]}/gitlab/config/gitlab.yml").with_content(/host: gitlab.fooboozoo.fr/)}
        it { should contain_file("#{params_set[:git_home]}/gitlab/config/gitlab.yml").with_content(/port: 80/)}
        it { should contain_file("#{params_set[:git_home]}/gitlab/config/gitlab.yml").with_content(/https: false/)}
        context 'with ssl' do
          let(:params) { params_set.merge(params_ssl) }
          it { should contain_file("#{params_set[:git_home]}/gitlab/config/gitlab.yml").with_content(/port: 443/)}
          it { should contain_file("#{params_set[:git_home]}/gitlab/config/gitlab.yml").with_content(/https: true/)}
        end
        context 'with non-default http ports' do
          let(:params) { params_set.merge!(:gitlab_http_port => '81') }
          it { should contain_file("#{params_set[:git_home]}/gitlab/config/gitlab.yml").with_content(/port: #{params_set[:gitlab_http_port]}/)}
          it { should contain_file("#{params_set[:git_home]}/gitlab/config/gitlab.yml").with_content(/https: false/)}
          context 'with non-default https ports' do
            let(:params) { params_set.merge!(:gitlab_ssl => true, :gitlab_ssl_self_signed => true, :gitlab_ssl_port => '443') }
            it { should contain_file("#{params_set[:git_home]}/gitlab/config/gitlab.yml").with_content(/port: #{params_set[:gitlab_ssl_port]}/)}
            it { should contain_file("#{params_set[:git_home]}/gitlab/config/gitlab.yml").with_content(/https: true/)}
          end
        end
        it { should contain_file("#{params_set[:git_home]}/gitlab/config/gitlab.yml").with_content(/relative_url_root: #{params_set[:gitlab_relative_url_root]}/)}
        it { should contain_file("#{params_set[:git_home]}/gitlab/config/gitlab.yml").with_content(/email_from: #{params_set[:git_email]}/)}
        it { should contain_file("#{params_set[:git_home]}/gitlab/config/gitlab.yml").with_content(/default_projects_limit: #{params_set[:gitlab_projects]}/)}
        it { should contain_file("#{params_set[:git_home]}/gitlab/config/gitlab.yml").with_content(/username_changing_enabled: #{params_set[:gitlab_username_change]}/)}
        it { should contain_file("#{params_set[:git_home]}/gitlab/config/gitlab.yml").with_content(/host: '#{params_set[:ldap_host]}'/)}
        it { should contain_file("#{params_set[:git_home]}/gitlab/config/gitlab.yml").with_content(/base: '#{params_set[:ldap_base]}'/)}
        it { should contain_file("#{params_set[:git_home]}/gitlab/config/gitlab.yml").with_content(/port: #{params_set[:ldap_port]}/)}
        it { should contain_file("#{params_set[:git_home]}/gitlab/config/gitlab.yml").with_content(/uid: '#{params_set[:ldap_uid]}'/)}
        it { should contain_file("#{params_set[:git_home]}/gitlab/config/gitlab.yml").with_content(/method: '#{params_set[:ldap_method]}'/)}
        it { should contain_file("#{params_set[:git_home]}/gitlab/config/gitlab.yml").with_content(/bind_dn: '#{params_set[:ldap_bind_dn]}'/)}
        it { should contain_file("#{params_set[:git_home]}/gitlab/config/gitlab.yml").with_content(/password: '#{params_set[:ldap_bind_password]}'/)}
        it { should contain_file("#{params_set[:git_home]}/gitlab/config/gitlab.yml").with_content(/path: #{params_set[:git_home]}\/gitlab-satellites\//)}
        it { should contain_file("#{params_set[:git_home]}/gitlab/config/gitlab.yml").with_content(/repos_path: #{params_set[:gitlab_repodir]}\/repositories\//)}
        it { should contain_file("#{params_set[:git_home]}/gitlab/config/gitlab.yml").with_content(/hooks_path: #{params_set[:git_home]}\/gitlab-shell\/hooks\//)}
      end # gitlab config
      describe 'resque config' do
        it { should contain_file("#{params_set[:git_home]}/gitlab/config/resque.yml").with(:ensure => 'file',:owner => params_set[:git_user],:group => params_set[:git_user])}
        it { should contain_file("#{params_set[:git_home]}/gitlab/config/resque.yml").with_content(/production: redis:\/\/#{params_set[:gitlab_redishost]}:#{params_set[:gitlab_redisport]}/)}
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
          :command => 'bundle install --without development aws test postgres --deployment',
          :unless  => 'bundle check',
          :cwd     => "#{params_set[:git_home]}/gitlab",
          :timeout => 0,
          :require => ["File[#{params_set[:git_home]}/gitlab/config/database.yml]",
                        "File[#{params_set[:git_home]}/gitlab/config/unicorn.rb]",
                        "File[#{params_set[:git_home]}/gitlab/config/gitlab.yml]",
                        "File[#{params_set[:git_home]}/gitlab/config/resque.yml]"]
        )}
        context 'postgresql' do
          let(:params) { params_set.merge({ :gitlab_dbtype => 'pgsql' }) }
          it { should contain_exec('install gitlab').with(
            :user    => params_set[:git_user],
            :path    => params_set[:exec_path],
            :command => 'bundle install --without development aws test mysql --deployment',
            :unless  => 'bundle check',
            :cwd     => "#{params_set[:git_home]}/gitlab",
            :timeout => 0,
            :require => ["File[#{params_set[:git_home]}/gitlab/config/database.yml]",
                          "File[#{params_set[:git_home]}/gitlab/config/unicorn.rb]",
                          "File[#{params_set[:git_home]}/gitlab/config/gitlab.yml]",
                          "File[#{params_set[:git_home]}/gitlab/config/resque.yml]"]
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
