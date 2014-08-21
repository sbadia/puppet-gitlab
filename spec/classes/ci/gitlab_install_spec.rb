require 'spec_helper'

# Gitlab
describe 'gitlab::ci' do
  let(:facts) {{
    :osfamily       => 'Debian',
    :fqdn           => 'gitlabci.fooboozoo.fr'
  }}

  ## Parameter set
  # a non-default common parameter set
  let :params_set do
    {
      :ci_user               => 'ci',
      :ci_home               => '/srv/ci',
      :ci_email              => 'ci@fooboozoo.fr',
      :gitlab_redishost      => 'redis.fooboozoo.fr',
      :gitlab_redisport      => '9736',
      :gitlab_dbname         => 'gitlab_production',
      :gitlab_dbuser         => 'baltig',
      :gitlab_dbpwd          => 'Cie7cheewei<ngi3',
      :gitlab_dbhost         => 'sql.fooboozoo.fr',
      :gitlab_dbport         => '2345',
      :gitlab_http_timeout   => '300',
      :gitlab_unicorn_port   => '8888',
      :gitlab_unicorn_worker => '8',
      :bundler_flags         => '--no-deployment',
      :bundler_jobs          => '2',
      :exec_path             => '/opt/bw/bin:/bin:/usr/bin:/usr/sbin:/sbin:/usr/local/bin:/usr/local/sbin',
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
  describe 'gitlab::ci::install' do
    context 'with default params' do
      describe 'install gitlab ci' do
        it { should contain_exec('install gitlab-ci').with(
          :user    => 'gitlab_ci',
          :path    => '/home/gitlab_ci/.rbenv/shims:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
          :command => "bundle install --without development aws test postgres --deployment",
          :unless  => 'bundle check',
          :cwd     => '/home/gitlab_ci/gitlab-ci',
          :timeout => 0,
          :require => ['Gitlab::Config::Database[gitlab-ci]',
                        'Gitlab::Config::Unicorn[gitlab-ci]',
                        'File[/home/gitlab_ci/gitlab-ci/config/application.yml]',
                        'Gitlab::Config::Resque[gitlab-ci]'],
          :notify  => 'Exec[run gitlab-ci migrations]'
        )}
        it { should contain_exec('run gitlab-ci migrations').with(
          :command     => 'bundle exec rake db:migrate RAILS_ENV=production',
          :cwd         => '/home/gitlab_ci/gitlab-ci',
          :refreshonly => 'true',
          :notify      => 'Exec[precompile gitlab-ci assets]'
        )}
        it { should contain_exec('run gitlab-ci schedules').with(
          :command     => 'bundle exec whenever -w RAILS_ENV=production',
          :cwd         => '/home/gitlab_ci/gitlab-ci',
          :refreshonly => 'true'
        )}
        context 'postgresql' do
          let(:params) {{ :gitlab_dbtype => 'pgsql' }}
          it { should contain_exec('install gitlab-ci').with(
            :user    => 'gitlab_ci',
            :path    => '/home/gitlab_ci/.rbenv/shims:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
            :command => "bundle install --without development aws test mysql --deployment",
            :unless  => 'bundle check',
            :cwd     => '/home/gitlab_ci/gitlab-ci',
            :timeout => 0,
            :require => ['Gitlab::Config::Database[gitlab-ci]',
                        'Gitlab::Config::Unicorn[gitlab-ci]',
                        'File[/home/gitlab_ci/gitlab-ci/config/application.yml]',
                        'Gitlab::Config::Resque[gitlab-ci]']
          )}
        end # pgsql
      end # install gitlab
      describe 'setup gitlab-ci database' do
        it { should contain_exec('setup gitlab-ci database').with(
          :user    => 'gitlab_ci',
          :path    => '/home/gitlab_ci/.rbenv/shims:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
          :command => '/usr/bin/yes yes | bundle exec rake setup RAILS_ENV=production && touch /home/gitlab_ci/.gitlab-ci_setup_done',
          :cwd     => '/home/gitlab_ci/gitlab-ci',
          :creates => '/home/gitlab_ci/.gitlab-ci_setup_done',
          :before  => 'Exec[run gitlab-ci migrations]',
          :require => 'Exec[install gitlab-ci]',
          :notify  => ['Exec[precompile gitlab-ci assets]','Exec[run gitlab-ci schedules]']
        )}
        it { should contain_exec('precompile gitlab-ci assets').with(
          :command     => 'bundle exec rake assets:clean assets:precompile cache:clear RAILS_ENV=production',
          :cwd         => '/home/gitlab_ci/gitlab-ci',
          :refreshonly => 'true'
        )}
      end # setup gitlab database
    end # defaults params
    context 'with specifics params' do
      let(:params) { params_set }

      describe 'install gitlab-ci' do
        it { should contain_exec('install gitlab-ci').with(
          :user    => params_set[:ci_user],
          :path    => params_set[:exec_path],
          :command => "bundle install --without development aws test postgres #{params_set[:bundler_flags]}",
          :unless  => 'bundle check',
          :cwd     => "#{params_set[:ci_home]}/gitlab-ci",
          :timeout => 0,
          :require => ['Gitlab::Config::Database[gitlab-ci]',
                       'Gitlab::Config::Unicorn[gitlab-ci]',
                       "File[#{params_set[:ci_home]}/gitlab-ci/config/application.yml]",
                       'Gitlab::Config::Resque[gitlab-ci]']
        )}
        context 'postgresql' do
          let(:params) { params_set.merge({ :gitlab_dbtype => 'pgsql' }) }
          it { should contain_exec('install gitlab-ci').with(
            :user    => params_set[:ci_user],
            :path    => params_set[:exec_path],
            :command => "bundle install --without development aws test mysql #{params_set[:bundler_flags]}",
            :unless  => 'bundle check',
            :cwd     => "#{params_set[:ci_home]}/gitlab-ci",
            :timeout => 0,
            :require => ['Gitlab::Config::Database[gitlab-ci]',
                       'Gitlab::Config::Unicorn[gitlab-ci]',
                       "File[#{params_set[:ci_home]}/gitlab-ci/config/application.yml]",
                       'Gitlab::Config::Resque[gitlab-ci]']
          )}
        end # pgsql
      end # install gitlab-ci
      describe 'setup gitlab-ci database' do
        it { should contain_exec('setup gitlab-ci database').with(
          :user    => params_set[:ci_user],
          :path    => params_set[:exec_path],
          :command => "/usr/bin/yes yes | bundle exec rake setup RAILS_ENV=production && touch #{params_set[:ci_home]}/.gitlab-ci_setup_done",
          :cwd     => "#{params_set[:ci_home]}/gitlab-ci",
          :creates => "#{params_set[:ci_home]}/.gitlab-ci_setup_done",
          :require => 'Exec[install gitlab-ci]'
        )}
      end # setup gitlab-ci database
    end # with params
  end # gitlab-ci::install
end # gitlab-ci
