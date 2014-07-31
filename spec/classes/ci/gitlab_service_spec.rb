require 'spec_helper'

# Gitlab
describe 'gitlab::ci' do
  let(:facts) {{
    :osfamily  => 'Debian',
    :fqdn      => 'gitlabci.fooboozoo.fr',
  }}

  ### Gitlab::service
  describe 'gitlab::ci::service' do
    it { should contain_service('gitlab_ci').with(
      :ensure     => 'running',
      :hasstatus  => 'true',
      :hasrestart => 'true',
      :enable     => 'true'
    )}
  end
end
