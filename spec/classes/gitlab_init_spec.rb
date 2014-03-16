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
      it { expect { subject }.to raise_error(Puppet::Error, /Rainbow not supported yet/)}
    end

    describe 'unknown dbtype' do
      let(:params) {{ :gitlab_dbtype => 'yatta' }}
      it { expect { subject }.to raise_error(Puppet::Error, /gitlab_dbtype is not supported/)}
    end
  end

end # gitlab
