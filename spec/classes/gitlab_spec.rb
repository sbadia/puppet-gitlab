require 'spec_helper'
#TODO
# validate params (init) bool/string
# ensure fail osfamily/dbtype
# regexp for gitlab/shell versions

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
      :git_user             => 'gitlab',
      :git_home             => '/srv/gitlab',
      :git_comment          => 'Labfooboozoo',
      :git_email            => 'gitlab@fooboozoo.fr',
      :gitlab_sources       => 'https://github.com/gitlabhq/gitlabhq',
      :gitlab_branch        => '4-2-woots',
      :gitlabshell_sources  => 'https://github.com/gitlabhq/gitlab-shell',
      :gitlabshell_branch   => 'v1.2.3',
      :gitlab_repodir       => '/mnt/nas',
      :gitlab_redishost     => 'redis.fooboozoo.fr',
      :gitlab_redisport     => '9736',
      :gitlab_dbname        => 'gitlab_production',
      :gitlab_dbuser        => 'baltig',
      :gitlab_dbpwd         => 'Cie7cheewei<ngi3',
      :gitlab_dbhost        => 'sql.fooboozoo.fr',
      :gitlab_dbport        => '2345'
    }
  end

  # a non-default parameter set for SSL support
  let :params_ssl do
    {
      :gitlab_ssl             => true,
      :gitlab_ssl_self_signed => true,
      :gitlab_ssl_cert        => '/srv/ssl/gitlab.pem',
      :gitlab_ssl_key         => '/srv/ssl/gitlab.key'
    }
  end


  ## Gitlab


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
                              'libyaml-devel']
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
        it { should contain_exec('download gitlab').with(
          :cwd     => '/home/git',
          :user    => 'git',
          :path    => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
          :command => 'git clone -b 6-2-stable git://github.com/gitlabhq/gitlabhq.git ./gitlab',
          :creates => '/home/git/gitlab'
        )}
        it { should contain_exec('download gitlab-shell').with(
          :cwd     => '/home/git',
          :user    => 'git',
          :path    => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
          :command => 'git clone -b v1.7.1 git://github.com/gitlabhq/gitlab-shell.git ./gitlab-shell',
          :creates => '/home/git/gitlab-shell'
        )}
      end
      context 'with specifics params' do
        let(:params) { params_set }
        it { should contain_exec('download gitlab').with(
          :cwd     => params_set[:git_home],
          :command => "git clone -b #{params_set[:gitlab_branch]} #{params_set[:gitlab_sources]} ./gitlab",
          :user    => params_set[:git_user],
          :path    => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
          :creates => "#{params_set[:git_home]}/gitlab"
        )}
        it { should contain_exec('download gitlab-shell').with(
          :cwd     => params_set[:git_home],
          :command => "git clone -b #{params_set[:gitlabshell_branch]} #{params_set[:gitlabshell_sources]} ./gitlab-shell",
          :user    => params_set[:git_user],
          :path    => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
          :creates => "#{params_set[:git_home]}/gitlab-shell"
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
        it { should contain_file('/home/git/gitlab/config/database.yml').with_content(/database: gitladb/)}
        it { should contain_file('/home/git/gitlab/config/database.yml').with_content(/username: gitladbu/)}
        it { should contain_file('/home/git/gitlab/config/database.yml').with_content(/password: changeme/)}
        it { should contain_file('/home/git/gitlab/config/database.yml').with_content(/host: localhost/)}
        context 'postgresql' do
          let(:params) {{ :gitlab_dbtype => 'pgsql' }}
          it { should contain_file('/home/git/gitlab/config/database.yml').with_content(/adapter: postgresql/)}
          it { should contain_file('/home/git/gitlab/config/database.yml').with_content(/encoding: unicode/)}
          it { should contain_file('/home/git/gitlab/config/database.yml').with_content(/database: gitladb/)}
          it { should contain_file('/home/git/gitlab/config/database.yml').with_content(/username: gitladbu/)}
          it { should contain_file('/home/git/gitlab/config/database.yml').with_content(/password: changeme/)}
          it { should contain_file('/home/git/gitlab/config/database.yml').with_content(/host: localhost/)}
          it { should contain_file('/home/git/gitlab/config/database.yml').with_content(/port: 5432/)}
        end # pgsql
      end # database config
      describe 'unicorn config' do
        it { should contain_file('/home/git/gitlab/config/unicorn.rb').with(:ensure => 'file',:owner => 'git',:group => 'git')}
        it { should contain_file('/home/git/gitlab/config/unicorn.rb').with_content(/worker_processes 2/)}
        it { should contain_file('/home/git/gitlab/config/unicorn.rb').with_content(/working_directory "\/home\/git\/gitlab"/)}
        it { should contain_file('/home/git/gitlab/config/unicorn.rb').with_content(/listen "\/home\/git\/gitlab\/tmp\/sockets\/gitlab.socket"/)}
        it { should contain_file('/home/git/gitlab/config/unicorn.rb').with_content(/pid "\/home\/git\/gitlab\/tmp\/pids\/unicorn.pid"/)}
        it { should contain_file('/home/git/gitlab/config/unicorn.rb').with_content(/stderr_path "\/home\/git\/gitlab\/log\/unicorn.stderr.log"/)}
        it { should contain_file('/home/git/gitlab/config/unicorn.rb').with_content(/stdout_path "\/home\/git\/gitlab\/log\/unicorn.stdout.log"/)}
      end # unicorn config
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
          :path     => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
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
        it { should contain_file("#{params_set[:git_home]}/gitlab/config/unicorn.rb").with_content(/worker_processes 2/)}
        it { should contain_file("#{params_set[:git_home]}/gitlab/config/unicorn.rb").with_content(/working_directory "#{params_set[:git_home]}\/gitlab"/)}
        it { should contain_file("#{params_set[:git_home]}/gitlab/config/unicorn.rb").with_content(/listen "#{params_set[:git_home]}\/gitlab\/tmp\/sockets\/gitlab.socket"/)}
        it { should contain_file("#{params_set[:git_home]}/gitlab/config/unicorn.rb").with_content(/pid "#{params_set[:git_home]}\/gitlab\/tmp\/pids\/unicorn.pid"/)}
        it { should contain_file("#{params_set[:git_home]}/gitlab/config/unicorn.rb").with_content(/stderr_path "#{params_set[:git_home]}\/gitlab\/log\/unicorn.stderr.log"/)}
        it { should contain_file("#{params_set[:git_home]}/gitlab/config/unicorn.rb").with_content(/stdout_path "#{params_set[:git_home]}\/gitlab\/log\/unicorn.stdout.log"/)}
      end # unicorn config
    end # with params
  end # gitlab::install

  ### Gitlab::config
  describe 'gitlab::config' do
    context 'with default params' do

    end
    context 'with specifics params' do
      let(:params) { params_set }
    end
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
