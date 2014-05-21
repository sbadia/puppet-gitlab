require 'spec_helper'

# Gitlab
describe 'gitlab' do
  let(:facts) {{
    :osfamily  => 'Debian',
    :fqdn      => 'gitlab.fooboozoo.fr',
    :processorcount => '2',
    :sshrsakey => 'AAAAB3NzaC1yc2EAAAA'
  }}

  ### Gitlab::service
  describe 'gitlab::service' do
    it { should contain_service('gitlab').with(
      :ensure     => 'running',
      :hasstatus  => 'true',
      :hasrestart => 'true',
      :enable     => 'true'
    )}
  end # gitlab::service
end # gitlab
