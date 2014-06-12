source 'https://rubygems.org'

if ENV.key?('PUPPET_GEM_VERSION')
  puppetversion = ENV['PUPPET_GEM_VERSION']
else
  puppetversion = ['>= 3.0']
end

gem 'rake', '10.1.0'
# rspec-puppet fetch the latest rspec (3.0.0)
# this version is a bit incompat. with older specs...
# http://myronmars.to/n/dev-blog/2014/05/notable-changes-in-rspec-3
gem 'rspec', '2.14.1'
gem 'puppet-lint', '~> 0.3.2'
gem 'rspec-puppet', :git => 'https://github.com/rodjek/rspec-puppet.git'
gem 'puppet-syntax'
gem 'puppet', puppetversion
gem 'puppetlabs_spec_helper'
