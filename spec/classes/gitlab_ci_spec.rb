require 'spec_helper'

# Gitlab
describe 'gitlab::ci' do

  describe 'gitlab::ci internal' do
    it { should contain_anchor('gitlab::ci::begin') }
    it { should contain_class('gitlab::ci::setup') }
    it { should contain_class('gitlab::ci::package') }
    it { should contain_class('gitlab::ci::install') }
    it { should contain_class('gitlab::ci::config') }
    it { should contain_class('gitlab::ci::service') }
    it { should contain_anchor('gitlab::ci::end') }

    it { should contain_class('gitlab::ci::params') }
    it { should contain_class('gitlab::ci') }
  end

end # gitlab::ci
