require 'spec_helper_acceptance'

describe 'gitlab class' do
  context 'using postgresql backend' do
    hosts.each do |host|
      if fact('osfamily') == 'RedHat'
        if fact('architecture') == 'amd64'
          on host, "wget http://download.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm; rpm -ivh epel-release-6-8.noarch.rpm"
        else
          on host, "wget http://download.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm; rpm -ivh epel-release-6-8.noarch.rpm"
        end
      end
    end

   it 'should work with no errors' do
     pp= <<-EOS
       include redis
       include nginx
       include postgresql::server
       include git
       include nodejs
       include logrotate

       postgresql::server::db { 'gitlab':
        user     => 'user',
        password => postgresql_password('user', 'password'),
       }

       class {'gitlab':
         git_user            => 'git',
         git_home            => '/home/git',
         git_email           => 'gitlab@fooboozoo.fr',
         git_comment         => 'GitLab',
         gitlab_sources      => 'https://github.com/gitlabhq/gitlabhq.git',
         gitlab_domain       => 'gitlab.localdomain.local',
         gitlab_http_timeout => '300',
         gitlab_dbtype       => 'pgsql',
         gitlab_backup       => true,
         gitlab_dbname       => 'gitlab',
         gitlab_dbuser       => 'user',
         gitlab_dbpwd        => 'password',
         gitlab_dbport       => '5432',
         ldap_enabled        => false,
       }
    EOS

    # Run it twice and test for idempotency
    apply_manifest(pp, :catch_failures => true)
    apply_manifest(pp, :catch_changes => true)
  end

 end
end
