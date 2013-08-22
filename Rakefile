# -*- mode: ruby -*-
# vi: set ft=ruby :
#
NAME = 'puppet-gitlab'
TDIR = File.expand_path(File.dirname(__FILE__))

require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet-lint/tasks/puppet-lint'

PuppetLint.configuration.send('disable_80chars')

def get_version
  if File.read(File.join(TDIR, 'Modulefile')) =~ /(\d+)\.(\d+)\.(\d+)/
    return [$1.to_i, $2.to_i, $3.to_i].compact.join('.')
  end
end # def:: get_version

def bump_version(level)
  version_txt = get_version
  if version_txt =~ /(\d+)\.(\d+)\.(\d+)/
    major = $1.to_i
    minor = $2.to_i
    patch = $3.to_i
  end

  case level
  when :major
    major += 1
    minor = 0
    patch = 0
  when :minor
    minor += 1
    patch = 0
  when :patch
    patch += 1
  end

  new_version = [major,minor,patch].compact.join('.')
  v = File.read(File.join(TDIR,'Modulefile')).chomp
  v.gsub!(/\w+\s'(\d+)\.(\d+)\.(\d+)'/,"version\ '#{new_version}'")
  File.open(File.join(TDIR,'Modulefile'), 'w') do |file|
    file.puts v
  end
end # def:: bump_version(level)

namespace :module do
  desc "New #{NAME} GIT release (v#{get_version})"
  task :release do
    sh "git tag #{get_version} -m \"New release: #{get_version}\""
    sh "git push --tag"
  end

  namespace :bump do
    desc "Bump #{NAME} by a major version"
    task :major do
      bump_version(:major)
    end

    desc "Bump #{NAME} by a minor version"
    task :minor do
      bump_version(:minor)
    end

    desc "Bump #{NAME} by a patch version"
    task :patch do
      bump_version(:patch)
    end
  end

  namespace :check do
    desc 'Check erb template syntax'
    task :erb do
      file=ARGV.values_at(Range.new(ARGV.index('check:erb')+1,-1))
      exec "erb -x -T '-' #{file} | ruby -c"
    end

    desc "Check pp file syntax (return nothing if ok)"
    task :pp do
      file=ARGV.values_at(Range.new(ARGV.index('check:pp')+1,-1))
      exec "puppet parser validate \"#{file}\""
    end

    desc "Check puppet syntax"
    task :syntax do
      file=ARGV.values_at(Range.new(ARGV.index('check:syntax')+1,-1))
      exec "puppet-lint \"#{file}\""
    end
  end

  desc "Build #{NAME} module (in a clean env) Please use this for puppetforge"
  task :build do
    exec "rsync -rv --exclude-from=#{TDIR}/.forgeignore . /tmp/puppet-gitlab"
    exec "cd /tmp/puppet-gitlab;puppet module build"
  end
end

task(:default).clear
task :default => :spec

