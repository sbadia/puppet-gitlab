source 'https://rubygems.org'

if ENV.key?('PUPPET_GEM_VERSION')
  puppetversion = ENV['PUPPET_GEM_VERSION']
else
  puppetversion = ['>= 3.0']
end

gem 'rake'
gem 'puppet-lint'
gem 'rspec-puppet', :git => 'https://github.com/rodjek/rspec-puppet.git'
gem 'puppet-syntax'
gem 'puppet', puppetversion
gem 'puppetlabs_spec_helper'
gem 'rspec-system'
gem 'rspec-system-puppet'
gem 'rspec-system-serverspec'
