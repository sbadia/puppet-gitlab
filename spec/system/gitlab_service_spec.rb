require 'spec_helper_system'


describe 'gitlab::service class' do
  let(:os) {
    node.facts['osfamily']
  }

  puppet_apply(%{
    class { 'gitlab': }
  })

  describe service('gitlab') do
    it { should be_enabled }
    it { should be_running }
  end

  decribe service('nginx') do
    it { should be_enabled }
    it { should be_running }
  end

end
