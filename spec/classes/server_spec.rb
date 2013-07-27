require 'spec_helper'

describe 'gitlab', :type => :class do
  context 'gitlab::server validation' do
    ['Debian','RedHat'].each do |distro|
      context  "while on #{distro} (Agnostic tests)" do
        let (:facts) { {  :osfamily => distro, :fqdn => 'fqdn.host.name' } }
        include_context "gitlab_shared"
        let (:pre_condition) { global_gitlab_variables }
        let (:params) { { :gitlab_dbpwd => 'foo@foo.com', :git_email => 'foo@site.com' } }
        context 'Classes:' do
          ['gitlab::server'].each do |classes|
            it "should contain class #{classes}" do
              should contain_class(classes)
            end
          end
        end

        context 'Execs:' do
          it 'should get gitlab' do
            should contain_exec('Get gitlab').with(
              :command=>"git clone -b 5-3-stable git://github.com/gitlabhq/gitlabhq.git ./gitlab",
              :creates=>"/home/git/gitlab",
              :cwd=>"/home/git",
              :user=>"git",
              :path=>"/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
              :logoutput=>"on_failure"
            )
          end
          it 'should install gitlab' do
            should contain_exec('Install gitlab').with(
              :command=>"bundle install --without development test postgres --deployment",
              :provider=>"shell",
              :cwd=>"/home/git/gitlab",
              :user=>"git",
              :unless=>"/usr/bin/test -f /home/git/.gitlab_setup_done",
              :timeout=>"0",
              :path=>"/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
              :logoutput=>"on_failure"
            )
          end
          it 'should setup the gitlab db' do
            should contain_exec('Setup gitlab DB').with(
              :command=>"/usr/bin/yes yes | bundle exec rake gitlab:setup RAILS_ENV=production",
              :provider=>"shell",
              :cwd=>"/home/git/gitlab",
              :user=>"git",
              :creates=>"/home/git/.gitlab_setup_done",
              :refreshonly=>true,
              :path=>"/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
              :logoutput=>"on_failure"
            )
          end
        end
        context 'Files:' do
          it { should contain_file("/home/git/.gitlab_setup_done")}

          context 'when configured to use mysql' do
            let (:params) { { :gitlab_dbtype => 'mysql', :gitlab_dbpwd => 'foo@foo.com', :git_email => 'foo@site.com' } }
            it 'should configure /home/git/gitlab/config/database.yml to use mysql' do
              should contain_file('/home/git/gitlab/config/database.yml').with(
                :ensure=>"file",
                :owner=>"git",
                :group=>"git",
              ).with_content(/mysql/)
            end
          end
          context 'when configured to use postgres' do
            let (:params) { { :gitlab_dbtype => 'pgsql', :gitlab_dbpwd => 'foo@foo.com', :git_email => 'foo@site.com' } }
            it 'should configure /home/git/gitlab/config/database.yml to use postgres' do
              should contain_file('/home/git/gitlab/config/database.yml').with(
                :ensure=>"file",
                :owner=>"git",
                :group=>"git",
              ).with_content(/postgres/)
            end
          end
          it '/home/git/gitlab/config/puma.rb' do
            should contain_file('/home/git/gitlab/config/puma.rb').with(
              :ensure=>"file",
              :owner=>"git",
              :group=>"git",
            ).with_content(/PUPPET/)
          end
          it '/home/git/gitlab/config/gitlab.yml' do
            should contain_file('/home/git/gitlab/config/gitlab.yml').with(
              :ensure=>"file",
              :owner=>"git",
              :group=>"git",
              :mode=>"0640",
            ).with_content(/PUPPET/)
          end
          ['/home/git/gitlab/tmp','/home/git/gitlab/log','/home/git/gitlab-satellites','/home/git/gitlab/public','/home/git/gitlab/public/uploads','/home/git/gitlab/tmp/pids','/home/git/gitlab/tmp/sockets'].each do |dirs|
            it "#{dirs}" do
              should contain_file(dirs).with(
                :ensure=>"directory",
                :mode=>"0755",
                :owner=>"git",
                :group=>"git",
              )
            end
          end
          it '/home/git/.gitconfig' do
            should contain_file('/home/git/.gitconfig').with(
              :mode=>"0644"
            ).with_content(/PUPPET/)
          end
          it '/etc/nginx/conf.d/gitlab.conf' do
            should contain_file('/etc/nginx/conf.d/gitlab.conf').with(
              :ensure=>"file",
              :owner=>"root",
              :group=>"root",
              :mode=>"0644",
            ).with_content(/GITLAB/)
          end
          it '/etc/init.d/gitlab' do
            should contain_file('/etc/init.d/gitlab').with(
              :ensure=>"file",
              :owner=>"root",
              :group=>"root",
              :mode=>"0755",
             ).with_content(/GitLab/)
          end
        end
        context 'Misc Resources:' do
          it 'should contain the localhost sshkey' do
            should contain_sshkey('localhost').with(
              :host_aliases => 'fqdn.host.name'
            )
          end
          it 'should contain the sudoers !requiretty augeas' do
            should contain_augeas('gitlab_nuke_requiretty').with(
              :context=>"/files/etc/sudoers",
              :changes=>['set Defaults[type=":root"]/type :root', 'set Defaults[type=":root"]/requiretty/negate ""']
            )
          end
        end
        context 'Packages:' do
          it { should contain_package('bundler').with(
            :provider   => 'gem',
            :ensure => 'installed'
          )}      

          it { should contain_package('charlock_holmes').with(
            :provider   => 'gem',
            :ensure => '0.6.9.4'
          )}
          #it { subject.resources.each do |resources|
          #  p
          #  p resources
          #  end
          #}
        end
      end
    end
    context 'While on Debian (specific tests)' do
      let (:facts) { {  :osfamily => 'Debian' } }
        include_context "gitlab_shared"
        let (:pre_condition) { global_gitlab_variables }
        let (:params) { { :gitlab_dbpwd => 'foo@foo.com', :git_email => 'foo@site.com' } }
      context 'Files:' do
        it 'bundle_config' do
          should contain_file('bundle_config').with(
            :path=>"/home/git/gitlab/.bundle/config",
            :replace=>false,
            :owner=>"git",
            :group=>"git"
          ).with_content(/BUNDLE_FROZEN/)
        end
        it '/home/git/gitlab/.bundle' do
          should contain_file('/home/git/gitlab/.bundle').with(
            :path=>"/home/git/gitlab/.bundle",
            :ensure=>"directory",
            :owner=>"git",
            :group=>"git",
          )
        end
        it '/var/lib/gitlab' do
          should contain_file('/var/lib/gitlab').with(
            :ensure=>"directory",
            :owner=>"git",
            :group=>"www-data",
            :mode=>"0775"
          )
        end
      end
    end
    context 'while on RedHat (specific tests)' do
      let (:facts) { {  :osfamily => 'RedHat' } }
        include_context "gitlab_shared"
        let (:pre_condition) { global_gitlab_variables }
        let (:params) { { :gitlab_dbpwd => 'foo@foo.com', :git_email => 'foo@site.com' } }
      context 'Files:' do
        it '/var/lib/gitlab' do
          should contain_file('/var/lib/gitlab').with(
            :ensure=>"directory",
            :owner=>"git",
            :group=>"nginx",
            :mode=>"0775"
          )
        end
      end
    end
  end
end