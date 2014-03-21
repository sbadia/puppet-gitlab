require 'spec_helper'

# Gitlab
describe 'gitlab' do
  let(:facts) {{
    :osfamily  => 'Debian',
    :fqdn      => 'gitlab.fooboozoo.fr',
    :sshrsakey => 'AAAAB3NzaC1yc2EAAAA'
  }}

  describe 'input validation' do

    describe 'on a unsupported os' do
      let(:facts) {{ :osfamily => 'Rainbow' }}
      it { should compile.and_raise_error(/Rainbow not supported yet/)}
    end

    describe 'unknown dbtype' do
      let(:params) {{ :gitlab_dbtype => 'yatta' }}
      it { should compile.and_raise_error(/gitlab_dbtype is not supported/)}
    end
  end

  describe 'gitlab internal' do
    it { should contain_anchor('gitlab::begin') }
    it { should contain_class('gitlab::setup') }
    it { should contain_class('gitlab::package') }
    it { should contain_class('gitlab::install') }
    it { should contain_class('gitlab::config') }
    it { should contain_class('gitlab::service') }
    it { should contain_anchor('gitlab::end') }

    it { should contain_class('gitlab::params') }
    it { should contain_class('gitlab') }
  end

end # gitlab
