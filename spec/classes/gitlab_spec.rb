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
      :git_user               => 'gitlab',
      :git_home               => '/srv/gitlab',
      :git_comment            => 'Labfooboozoo',
      :git_email              => 'gitlab@fooboozoo.fr',
      :gitlab_sources         => 'https://github.com/gitlabhq/gitlabhq',
      :gitlab_branch          => '4-2-stable',
      :gitlabshell_sources    => 'https://github.com/gitlabhq/gitlab-shell',
      :gitlabshell_branch     => 'v1.2.3',
      :gitlab_repodir         => '/mnt/nas',
      :gitlab_redishost       => 'redis.fooboozoo.fr',
      :gitlab_redisport       => '9736',
      :gitlab_dbname          => 'gitlab_production',
      :gitlab_dbuser          => 'baltig',
      :gitlab_dbpwd           => 'Cie7cheewei<ngi3',
      :gitlab_dbhost          => 'sql.fooboozoo.fr',
      :gitlab_dbport          => '2345',
      :gitlab_http_timeout    => '300',
      :gitlab_projects        => '42',
      :gitlab_username_change => false,
      :gitlab_unicorn_port    => '8888',
      :gitlab_unicorn_worker  => '8',
      :exec_path              => '/opt/bw/bin:/bin:/usr/bin:/usr/sbin:/sbin:/usr/local/bin:/usr/local/sbin',
      :ldap_host              => 'ldap.fooboozoo.fr',
      :ldap_base              => 'dc=fooboozoo,dc=fr',
      :ldap_port              => '666',
      :ldap_uid               => 'cn',
      :ldap_method            => 'tls',
      :ldap_bind_dn           => 'uid=gitlab,o=bots,dc=fooboozoo,dc=fr',
      :ldap_bind_password     => 'aV!oo1ier5ahch;a'
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

  # a non-default parameter set with non-default http port
  let :params_non do
    {
      :gitlab_http_port       => '81'
    }
  end

  ## Gitlab
  describe 'input validation' do
    describe 'on a unsupported os' do
      let(:facts) {{ :osfamily => 'Rainbow' }}
      it { expect { subject }.to raise_error(Puppet::Error, /Rainbow not supported yet/)}
    end
    describe 'unknown dbtype' do
      let(:params) {{ :gitlab_dbtype => 'yatta' }}
      it { expect { subject }.to raise_error(Puppet::Error, /gitlab_dbtype is not supported/)}
    end
  end

  ## Gitlab::setup
  describe 'gitlab::setup' do

    ### User, gitconfig, home and satellites
    describe 'user, home, gitconfig and GitLab satellites' do
      context 'with default params' do
        it { should contain_user('git').with(
          :ensure   => 'present',
          :shell    => '/bin/bash',
          :password => '*',
          :home     => '/home/git',
          :comment  => 'GitLab',
          :system   => true
        )}
        it { should contain_file('/home/git/.gitconfig').with_content(/name = "GitLab"/)}
        it { should contain_file('/home/git/.gitconfig').with_content(/email = git@someserver.net/)}
        ['/home/git','/home/git/gitlab-satellites'].each do |file|
          it { should contain_file(file).with(:ensure => 'directory',:mode => '0755')}
        end
      end
      context 'with specifics params' do
        let(:params) { params_set }
        it { should contain_user('gitlab').with(
          :ensure   => 'present',
          :shell    => '/bin/bash',
          :password => '*',
          :home     => params_set[:git_home],
          :comment  => params_set[:git_comment],
          :system   => true
        )}
        it { should contain_file('/srv/gitlab/.gitconfig').with_content(/name = "GitLab"/)}
        it { should contain_file('/srv/gitlab/.gitconfig').with_content(/email = #{params_set[:git_email]}/)}
        ['/srv/gitlab','/srv/gitlab/gitlab-satellites'].each do |file|
          it { should contain_file(file).with(:ensure => 'directory',:mode => '0755')}
        end
      end
    end

    ### Sshkey
    describe  'sshkey (hostfile)' do
      it { should contain_sshkey('localhost').with(
        :ensure       => 'present',
        :host_aliases => 'gitlab.fooboozoo.fr',
        :key          => 'AAAAB3NzaC1yc2EAAAA',
        :type         => 'ssh-rsa'
      )}
    end

    ### Packages setup
    #= Packages helper
    p = {
      'Debian' => {
        'db_packages' => {
          'mysql' => ['libmysql++-dev','libmysqlclient-dev'],
          'pgsql' => ['libpq-dev', 'postgresql-client']
        },
        'system_packages' => ['libicu-dev', 'python2.7','python-docutils',
                              'libxml2-dev','libxslt1-dev','python-dev']
      },
      'RedHat' => {
        'db_packages' => {
          'mysql' => ['mysql-devel'],
          'pgsql' => ['postgresql-devel']
        },
        'system_packages' => ['libicu-devel','perl-Time-HiRes','libxml2-devel',
                              'libxslt-devel','python-devel','libcurl-devel',
                              'readline-devel','openssl-devel','zlib-devel',
                              'libyaml-devel','patch','gcc-c++']
      }
    }

    #### Db and devel packages
    describe 'packages' do
      #= On each distro
      ['Debian','RedHat'].each do |distro|
        #= With each dbtype
        ['mysql','pgsql'].each do |dbtype|
          context "for #{dbtype} devel on #{distro}" do
            let(:facts) {{ :osfamily => distro }}
            let(:params) {{ :gitlab_dbtype => dbtype }}
            p[distro]['db_packages'][dbtype].each do |pkg|
              it { should contain_package(pkg) }
            end
          end
        end
        context "for devel dependencies on #{distro}" do
          let(:facts) {{ :osfamily => distro }}
          p[distro]['system_packages'].each do |pkg|
            it { should contain_package(pkg) }
          end
        end
      end
      #### Gems (all dist.)
      describe 'commons gems' do
        it { should contain_package('bundler').with(
          :ensure   => 'installed',
          :provider => 'gem'
        )}
        it { should contain_package('charlock_holmes').with(
          :ensure   => '0.6.9.4',
          :provider => 'gem'
        )}
      end
      #### Commons packages (all dist.)
      describe 'commons packages' do
        ['git-core','postfix','curl'].each do |pkg|
          it { should contain_package(pkg) }
        end
      end
    end # packages
  end # gitlab::setup

  ## Gitlab::package
  describe 'gitlab::package' do
    describe 'get gitlab{-shell} sources' do
      context 'with default params' do
        it { should contain_vcsrepo('/home/git/gitlab').with(
          :ensure   => 'present',
          :user     => 'git',
          :provider => 'git',
          :source   => 'git://github.com/gitlabhq/gitlabhq.git',
          :revision => '6-5-stable'
        )}
        it { should contain_vcsrepo('/home/git/gitlab-shell').with(
          :ensure   => 'present',
          :user     => 'git',
          :provider => 'git',
          :source   => 'git://github.com/gitlabhq/gitlab-shell.git',
          :revision => 'v1.8.0'
        )}
      end
      context 'with specifics params' do
        let(:params) { params_set }
        it { should contain_vcsrepo("#{params_set[:git_home]}/gitlab").with(
          :ensure   => 'present',
          :user     => params_set[:git_user],
          :provider => 'git',
          :source   => params_set[:gitlab_sources],
          :revision => params_set[:gitlab_branch]
        )}
        it { should contain_vcsrepo("#{params_set[:git_home]}/gitlab-shell").with(
          :ensure   => 'present',
          :user     => params_set[:git_user],
          :provider => 'git',
          :source   => params_set[:gitlabshell_sources],
          :revision => params_set[:gitlabshell_branch]
        )}
      end
    end # get gitlab sources
  end # gitlab::package

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
        it { should contain_file('/home/git/gitlab/config/resque.yml').with_content(/production: redis:\/\/127.0.0.1/)}
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
          let(:params) { params_set.merge(params_non) }
          it { should contain_file("#{params_set[:git_home]}/gitlab/config/gitlab.yml").with_content(/port: #{params_set[:gitlab_http_port]}/)}
          it { should contain_file("#{params_set[:git_home]}/gitlab/config/gitlab.yml").with_content(/https: false/)}
          context 'with non-default https ports' do
            let(:params) { params_set.merge(params_ssl_non) }
            it { should contain_file("#{params_set[:git_home]}/gitlab/config/gitlab.yml").with_content(/port: #{params_set[:gitlab_ssl_port]}/)}
            it { should contain_file("#{params_set[:git_home]}/gitlab/config/gitlab.yml").with_content(/https: true/)}
          end
        end
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
        it { should contain_file("#{params_set[:git_home]}/gitlab/config/resque.yml").with_content(/production: redis:\/\/redis.fooboozoo.fr/)}
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

  ### Gitlab::config
  describe 'gitlab::config' do
    context 'with default params' do
      describe 'nginx config' do
        it { should contain_file('/etc/nginx/conf.d/gitlab.conf').with(
          :ensure => 'file',
          :owner  => 'root',
          :group  => 'root',
          :mode   => '0644'
        )}
        it { should contain_file('/etc/nginx/conf.d/gitlab.conf').with_content(/server unix:\/home\/git\/gitlab\/tmp\/sockets\/gitlab.socket;/)}
        it { should contain_file('/etc/nginx/conf.d/gitlab.conf').with_content(/listen 80;/)}
        it { should contain_file('/etc/nginx/conf.d/gitlab.conf').with_content(/server_name gitlab.fooboozoo.fr;/)}
        it { should contain_file('/etc/nginx/conf.d/gitlab.conf').with_content(/server_tokens off;/)}
        it { should contain_file('/etc/nginx/conf.d/gitlab.conf').with_content(/root \/home\/git\/gitlab\/public;/)}
        it { should contain_file('/etc/nginx/conf.d/gitlab.conf').with_content(/proxy_read_timeout 60;/)}
        it { should contain_file('/etc/nginx/conf.d/gitlab.conf').with_content(/proxy_connect_timeout 60;/)}
      end # nginx config
      describe 'gitlab init' do
        it { should contain_file('/etc/default/gitlab').with(
          :ensure => 'file',
          :owner  => 'root',
          :group  => 'root',
          :mode   => '0644'
        )}
        it { should contain_file('/etc/default/gitlab').with_content(/app_root="\/home\/git\/gitlab"/)}
        it { should contain_file('/etc/default/gitlab').with_content(/app_user="git"/)}
      end # gitlab default
      describe 'gitlab init' do
        it { should contain_file('/etc/init.d/gitlab').with(
          :ensure  => 'file',
          :owner   => 'root',
          :group   => 'root',
          :mode    => '0755',
          :require => 'File[/etc/default/gitlab]',
          :source  => '/home/git/gitlab/lib/support/init.d/gitlab'
        )}
      end # gitlab init
      describe 'gitlab logrotate' do
        it { should contain_file("/etc/logrotate.d/gitlab").with(
          :ensure => 'file',
          :source => '/home/git/gitlab/lib/support/logrotate/gitlab',
          :owner  => 'root',
          :group  => 'root',
          :mode   => '0644'
        )}
      end # gitlab logrotate
      describe 'gitlab directories' do
        ['gitlab/tmp','gitlab/tmp/pids','gitlab/tmp/sockets','gitlab/log','gitlab/public','gitlab/public/uploads'].each do |dir|
          it { should contain_file("/home/git/#{dir}").with(
            :ensure => 'directory',
            :mode   => '0755'
          )}
        end
      end # gitlab directories
      describe 'python2 symlink' do
        it { should contain_file('/usr/bin/python2').with(:ensure => 'link',:target => '/usr/bin/python')}
      end # python2 symlink
    end # default params
    context 'with specifics params' do
      let(:params) { params_set }
      describe 'nginx config' do
        it { should contain_file('/etc/nginx/conf.d/gitlab.conf').with(
          :ensure => 'file',
          :owner  => 'root',
          :group  => 'root',
          :mode   => '0644'
        )}
        it { should contain_file('/etc/nginx/conf.d/gitlab.conf').with_content(/server unix:#{params_set[:git_home]}\/gitlab\/tmp\/sockets\/gitlab.socket;/)}
        it { should contain_file('/etc/nginx/conf.d/gitlab.conf').with_content(/server_name gitlab.fooboozoo.fr;/)}
        it { should contain_file('/etc/nginx/conf.d/gitlab.conf').with_content(/server_tokens off;/)}
        it { should contain_file('/etc/nginx/conf.d/gitlab.conf').with_content(/root #{params_set[:git_home]}\/gitlab\/public;/)}
        it { should contain_file('/etc/nginx/conf.d/gitlab.conf').with_content(/proxy_read_timeout #{params_set[:gitlab_http_timeout]};/)}
        it { should contain_file('/etc/nginx/conf.d/gitlab.conf').with_content(/proxy_connect_timeout #{params_set[:gitlab_http_timeout]};/)}
        context 'with ssl' do
          let(:params) { params_set.merge(params_ssl) }
          it { should contain_file('/etc/nginx/conf.d/gitlab.conf').with_content(/listen 443;/)}
          it { should contain_file('/etc/nginx/conf.d/gitlab.conf').with_content(/ssl_certificate               \/etc\/ssl\/certs\/ssl-cert-snakeoil.pem;/)}
          it { should contain_file('/etc/nginx/conf.d/gitlab.conf').with_content(/ssl_certificate_key           \/etc\/ssl\/private\/ssl-cert-snakeoil.key;/)}
          it { should contain_file('/etc/nginx/conf.d/gitlab.conf').with_content(/proxy_set_header   X-Forwarded-Ssl   on;/)}
        end
        context 'with ssl and custom certs' do
          let(:params) { params_set.merge(params_ssl.merge({:gitlab_ssl_cert => '/srv/ssl/gitlab.pem',:gitlab_ssl_key => '/srv/ssl/gitlab.key'})) }
            it { should contain_file('/etc/nginx/conf.d/gitlab.conf').with_content(/ssl_certificate               \/srv\/ssl\/gitlab.pem;/)}
            it { should contain_file('/etc/nginx/conf.d/gitlab.conf').with_content(/ssl_certificate_key           \/srv\/ssl\/gitlab.key;/)}
        end
      end # nginx config
      describe 'gitlab default' do
        it { should contain_file('/etc/default/gitlab').with(
          :ensure => 'file',
          :owner  => 'root',
          :group  => 'root',
          :mode   => '0644'
        )}
        it { should contain_file('/etc/default/gitlab').with_content(/app_root="#{params_set[:git_home]}\/gitlab"/)}
        it { should contain_file('/etc/default/gitlab').with_content(/app_user="#{params_set[:git_user]}"/)}
      end # gitlab default
      describe 'gitlab init' do
        it { should contain_file('/etc/init.d/gitlab').with(
          :ensure  => 'file',
          :owner   => 'root',
          :group   => 'root',
          :mode    => '0755',
          :require => 'File[/etc/default/gitlab]',
          :source  => "#{params_set[:git_home]}/gitlab/lib/support/init.d/gitlab"
        )}
      end # gitlab init
      describe 'gitlab logrotate' do
        it { should contain_file("/etc/logrotate.d/gitlab").with(
          :ensure => 'file',
          :source => "#{params_set[:git_home]}/gitlab/lib/support/logrotate/gitlab",
          :owner  => 'root',
          :group  => 'root',
          :mode   => '0644'
        )}
      end # gitlab logrotate
      describe 'gitlab directories' do
        ['gitlab/tmp','gitlab/tmp/pids','gitlab/tmp/sockets','gitlab/log','gitlab/public','gitlab/public/uploads'].each do |dir|
          it { should contain_file("#{params_set[:git_home]}/#{dir}").with(
            :ensure => 'directory',
            :mode   => '0755'
          )}
        end
      end # gitlab directories
      describe 'python2 symlink' do
        it { should contain_file('/usr/bin/python2').with(:ensure => 'link',:target => '/usr/bin/python')}
      end # python2 symlink
    end # specifics params
  end # gitlab::config

  ### Gitlab::service
  describe 'gitlab::service' do
    it { should contain_service('gitlab').with(
      :ensure     => 'running',
      :hasstatus  => 'true',
      :hasrestart => 'true',
      :enable     => 'true'
    )}
  end # gitlab::service
end # gitlab
