require 'spec_helper'

# Gitlab
describe 'gitlab' do

  ### Gitlab::service
  describe 'gitlab::service' do
    it { is_expected.to contain_service('gitlab').with(
      :ensure     => 'running',
      :hasstatus  => 'true',
      :hasrestart => 'true',
      :enable     => 'true'
    )}
  end # gitlab::service
end # gitlab
