require 'spec_helper'

describe 'gitlab', :type => :class do
  #debug to see catalog
  #  it { p subject.resources }
  context 'input validation' do
    include_context "gitlab_shared"
    let :pre_condition do
      global_gitlab_variables
    end
    context 'when gitlab_dbpwd is not changed' do
      let (:params) { { :git_email => 'foo@foo.com' } }
      let (:facts)  { { :osfamily => 'RedHat' } }
      it 'should fail' do
        expect { subject }.to raise_error(Puppet::Error, /Please set the gitlab db password/)
      end
    end
    context 'when gitlab_dbpwd is not a string' do
      let (:params) { { :git_email => 'foo@foo.com', :gitlab_dbpwd => true } }
      let (:facts)  { { :osfamily => 'RedHat' } }
      it 'should fail' do
        expect { subject }.to raise_error(Puppet::Error, /is not a string./)
      end
    end
    context 'when git_email is not changed' do
      let (:params) { { :gitlab_dbpwd => 'foo@foo.com' } }
      let (:facts)  { { :osfamily => 'RedHat' } }
      it 'should fail' do
        expect { subject }.to raise_error(Puppet::Error, /Please set the email parameter/)
      end
    end
    context 'when git_email is not a string' do
      let (:params) { { :gitlab_dbpwd => 'foo@foo.com', :git_email => true } }
      let (:facts)  { { :osfamily => 'RedHat' } }
      it 'should fail' do
        expect { subject }.to raise_error(Puppet::Error, /is not a string./)
      end
    end
    ['git_user', 'git_home', 'git_comment', 'gitlab_sources', 'gitlab_branch', 'gitlabshell_branch', 'gitlabshell_sources', 'gitlab_dbtype', 'gitlab_dbname', 'gitlab_dbuser', 'gitlab_dbhost', 'gitlab_dbport', 'gitlab_domain', 'gitlab_repodir', 'gitlab_projects', 'nginx_service_name'].each do |strings|
      context  "when #{strings} is not a string" do
        let (:params) { { :gitlab_dbpwd => 'foo', :git_email => 'foo@foo.com', strings => true } }
        let (:facts)  { { :osfamily => 'RedHat' } }
        it 'should fail' do
          expect { subject }.to raise_error(Puppet::Error, /is not a string./)
        end
      end 
    end
    context 'when gitlab_ssl is true' do
      ['gitlab_ssl_cert', 'gitlab_ssl_key'].each do |sslparams|
        context  "and #{sslparams} is not a string" do
          let (:params) { { :gitlab_dbpwd => 'foo', :git_email => 'foo@foo.com',:gitlab_ssl => true, sslparams => true } }
          let (:facts)  { { :osfamily => 'RedHat' } }
          it 'should fail' do
            expect { subject }.to raise_error(Puppet::Error, /is not a string./)
          end
        end 
      end
    end
    context 'when ldap_enabled is true' do
      [ 'ldap_host', 'ldap_base', 'ldap_uid', 'ldap_port', 'ldap_method', 'ldap_bind_dn', 'ldap_bind_password'].each do |ldapparams|
        context  "and #{ldapparams} is not a string" do
          let (:params) { { :gitlab_dbpwd => 'foo', :git_email => 'foo@foo.com',:ldap_enabled => true, ldapparams => true } }
          let (:facts)  { { :osfamily => 'RedHat' } }
          it 'should fail' do
            expect { subject }.to raise_error(Puppet::Error, /is not a string./)
          end
        end 
      end
    end
    ['gitlab_ssl', 'ldap_enabled'].each do |bools|
      context "when #{bools} is not a boolean" do
        let (:params) { { :gitlab_dbpwd => 'foo', :git_email => 'foo@foo.com', bools => 'BOGON' } }
        let (:facts)  { { :osfamily => 'RedHat' } }
        it do
          expect { subject }.to raise_error(Puppet::Error, /"BOGON" is not a boolean./)
        end
      end
    end
  end
  ['mysql_dev_pkg_names', 'pg_dev_pkg_names'].each do |arrays|
    context "when #{arrays} is not an array" do
      let (:params) { { :gitlab_dbpwd => 'foo', :git_email => 'foo@foo.com',  arrays => true } }
      let (:facts)  { { :osfamily => 'RedHat' } }
      it do
        expect { subject }.to raise_error(Puppet::Error, /not an Array./)
      end
    end
  end
  describe 'on an unsupported os' do
    include_context "gitlab_shared"
    let (:params) { { :gitlab_dbpwd => 'foo', :git_email => 'foo@foo.com', :mysql_dev_pkg_names => ['foo','bar'], :pg_dev_pkg_names => ['bar','foo']} }
    let (:facts) { {  :osfamily => 'Rainbow Unicorn' } }
    it do
      expect { subject }.to raise_error(Puppet::Error, /Rainbow Unicorn not supported yet/)
    end
  end
end
