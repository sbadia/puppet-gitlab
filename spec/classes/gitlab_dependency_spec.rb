require 'spec_helper'

# Gitlab
describe 'gitlab' do

  ## Gitlab::setup
  describe 'gitlab::dependency' do

    ### Packages setup
    #= Packages helper
    p = {
      'Debian' => {
        'db_packages' => {
          'mysql' => ['libmysql++-dev','libmysqlclient-dev'],
          'pgsql' => ['libpq-dev']
        },
        'system_packages' => ['libicu-dev', 'python2.7','python-docutils',
                              'libxml2-dev','libxslt1-dev','python-dev'],
        'git_packages' => ['git-core']
      },
      'RedHat' => {
        'db_packages' => {
          'mysql' => ['mysql-devel'],
          'pgsql' => ['postgresql-devel']
        },
        'system_packages' => ['libicu-devel','perl-Time-HiRes','libxml2-devel',
                              'libxslt-devel','python-devel','libcurl-devel',
                              'readline-devel','openssl-devel','zlib-devel',
                              'libyaml-devel','patch','gcc-c++'],
        'git_packages' => ['git']
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
          p[distro]['git_packages'].each do |pkg|
            it { should contain_package(pkg) }
          end
        end
      end
      #### Commons packages (all dist.)
      describe 'commons packages' do
        ['git-core','postfix','curl'].each do |pkg|
          it { should contain_package(pkg) }
        end
      end
    end # packages
  end # gitlab::dependency
end # gitlab
