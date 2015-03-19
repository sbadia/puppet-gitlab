# -*- mode: ruby -*-
# vi: set ft=ruby :
#
# Managed by modulesync
# Configs https://github.com/sbadia/modulesync_configs/
#
require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet_blacksmith/rake_tasks'
require 'puppet-lint/tasks/puppet-lint'
require 'puppet-syntax/tasks/puppet-syntax'

TDIR = File.expand_path(File.dirname(__FILE__))
NAME = "sbadia-#{File.basename(TDIR).split('-')[1]}"

exclude_path = ["spec/**/*","pkg/**/*","vendor/**/*"]

PuppetLint.configuration.fail_on_warnings = true
PuppetLint.configuration.send('disable_80chars')
PuppetLint.configuration.send('disable_variable_scope')
PuppetLint.configuration.send('disable_class_parameter_defaults')
PuppetLint.configuration.send('disable_class_inherits_from_params_class')
PuppetLint.configuration.ignore_paths = exclude_path
PuppetSyntax.exclude_paths = exclude_path

namespace :module do
  desc "Build #{NAME} module (in a clean env, for puppetforge)"
  task :build do
    exec "rsync -rv --exclude-from=#{TDIR}/.forgeignore . /tmp/#{NAME};cd /tmp/#{NAME};puppet module build"
  end
end
