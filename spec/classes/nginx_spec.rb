require 'spec_helper'

describe 'gitlab::nginx' do

  describe 'on a debian based os' do
    let :facts do
      { :osfamily => 'Debian'}
    end
    
    it { should contain_package('mysql_client').with(
      :name   => 'mysql-client',
      :ensure => 'present'
    )}
  end

end