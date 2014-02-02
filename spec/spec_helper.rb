require 'puppetlabs_spec_helper/module_spec_helper'
require 'shared_examples'
#require 'simplecov'
#
#SimpleCov.start do
#    add_filter "/spec/"
#end

RSpec.configure do |c|
  c.alias_it_should_behave_like_to :it_configures, 'configures'
  c.alias_it_should_behave_like_to :it_raises, 'raises'
end
