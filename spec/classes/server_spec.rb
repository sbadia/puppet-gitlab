require 'spec_helper'

describe 'gitlab::server' do

  describe 'on a debian based os' do
    include_context "gitlab_shared"

    let :facts do
      {  :osfamily => 'Debian' }
    end

    let :pre_condition do
      global_gitlab_variables
    end

    it { should contain_package('nginx').with(
      :name   => 'nginx',
      :ensure => 'latest'
    )}

    it { should contain_package('bundler').with(
      :provider   => 'gem',
      :ensure => 'installed'
    )}

    it { should contain_package('charlock_holmes').with(
      :provider   => 'gem',
      :ensure => '0.6.9'
    )}

    it { should contain_package('Pygments').with(
      :provider   => 'pip',
      :ensure => 'installed'
    )}

  end
end
