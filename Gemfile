# Managed by modulesync
# Configs https://github.com/sbadia/modulesync_configs/
#
source ENV['GEM_SOURCE'] || "https://rubygems.org"

group :development, :unit_tests do
  gem 'puppetlabs_spec_helper',                :require => false
  gem 'rspec-puppet', '2.0.1',                 :require => false
  gem 'puppet-blacksmith',                     :require => false
  gem 'puppet-lint-param-docs',                :require => false
  gem 'puppet-lint-absolute_classname-check',  :require => false
  gem 'puppet-lint-absolute_template_path',    :require => false
  gem 'puppet-lint-trailing_newline-check',    :require => false
  gem 'puppet-lint-unquoted_string-check',     :require => false
  gem 'puppet-lint-leading_zero-check',        :require => false
  gem 'puppet-lint-variable_contains_upcase',  :require => false
  gem 'puppet-lint-numericvariable',           :require => false
  gem 'puppet-lint-file_ensure-check',         :require => false
  gem 'puppet-lint-trailing_comma-check',      :require => false
  gem 'metadata-json-lint',                    :require => false
  gem 'puppet_facts',                          :require => false
  gem 'json',                                  :require => false
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
