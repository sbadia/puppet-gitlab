# Managed by modulesync
# Configs https://github.com/sbadia/modulesync_configs/
#
source ENV['GEM_SOURCE'] || "https://rubygems.org"

group :development, :unit_tests do
  gem 'rake',                    :require => false
  gem 'puppetlabs_spec_helper',  :require => false
  gem 'rspec-puppet',            :require => false
  gem 'puppet-syntax',           :require => false
  gem 'puppet-lint',             :require => false
  gem 'puppet-lint-param-docs',  :require => false
  gem 'metadata-json-lint',      :require => false
  gem 'puppet_facts',            :require => false
  gem 'json',                    :require => false
end

group :system_tests do
  gem 'beaker-rspec',  :require => false
end

if facterversion = ENV['FACTER_GEM_VERSION']
  gem 'facter', facterversion, :require => false
else
  gem 'facter', :require => false
end

if puppetversion = ENV['PUPPET_GEM_VERSION']
  gem 'puppet', puppetversion, :require => false
else
  gem 'puppet', :require => false
end

# vim:ft=ruby
