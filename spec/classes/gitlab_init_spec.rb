require 'spec_helper'

# Gitlab
describe 'gitlab' do

  describe 'input validation' do

    describe 'on a unsupported os' do
      let(:facts) {{ :osfamily => 'Rainbow' }}
      it { is_expected.to compile.and_raise_error(/Rainbow not supported yet/)}
    end

    describe 'unknown dbtype' do
      let(:params) {{ :gitlab_dbtype => 'yatta' }}
      it { is_expected.to compile.and_raise_error(/gitlab_dbtype is not supported/)}
    end
  end

  describe 'gitlab internal' do
    it { is_expected.to contain_anchor('gitlab::begin') }
    it { is_expected.to contain_class('gitlab::setup') }
    it { is_expected.to contain_class('gitlab::package') }
    it { is_expected.to contain_class('gitlab::install') }
    it { is_expected.to contain_class('gitlab::config') }
    it { is_expected.to contain_class('gitlab::service') }
    it { is_expected.to contain_anchor('gitlab::end') }

    it { is_expected.to contain_class('gitlab::params') }
    it { is_expected.to contain_class('gitlab') }
  end

end # gitlab
