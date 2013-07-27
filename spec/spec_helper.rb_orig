dir = File.expand_path(File.dirname(__FILE__))
$LOAD_PATH.unshift File.join(dir, 'lib')

# Don't want puppet getting the command line arguments for rake or autotest
ARGV.clear

require 'puppet'
require 'facter'
#require 'mocha'
gem 'rspec', '>=2.0.0'
require 'rspec/expectations'
require 'rspec-puppet'
require 'puppetlabs_spec_helper/module_spec_helper'
require 'gitlab_shared'

RSpec.configure do |config|
  @gitlab_variables = "$abc=123"

  config.color_enabled = true
  config.before :each do
    # Ensure that we don't accidentally cache facts and environment between
    # test cases.  This requires each example group to explicitly load the
    # facts being exercised with something like
    # Facter.collection.loader.load(:ipaddress)
    Facter::Util::Loader.any_instance.stubs(:load_all)
    Facter.clear
    Facter.clear_messages
  end
end
