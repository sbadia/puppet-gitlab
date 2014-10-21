require 'spec_helper'

# Gitlab
describe 'gitlab::ci' do

  describe 'gitlab::ci internal' do
    it { is_expected.to contain_anchor('gitlab::ci::begin') }
    it { is_expected.to contain_class('gitlab::ci::setup') }
    it { is_expected.to contain_class('gitlab::ci::package') }
    it { is_expected.to contain_class('gitlab::ci::install') }
    it { is_expected.to contain_class('gitlab::ci::config') }
    it { is_expected.to contain_class('gitlab::ci::service') }
    it { is_expected.to contain_anchor('gitlab::ci::end') }

    it { is_expected.to contain_class('gitlab::ci::params') }
    it { is_expected.to contain_class('gitlab::ci') }
  end

end # gitlab::ci
