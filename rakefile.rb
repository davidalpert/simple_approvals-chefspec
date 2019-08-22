# encoding: utf-8
$: << './'

require 'rubygems'
require 'bundler/setup'

require 'version_bumper'
require 'bundler'
require 'bundler/gem_helper'
require 'geminabox_client'

# Helper for setting version
module SimpleApprovals
  # Helper for setting version
  class GemHelper < Bundler::GemHelper
    def reload_version
      @gemspec.version = SimpleApprovals::gem_version
    end

  end

  # The current version of the gem
  def self.gem_version
    File.read('VERSION').strip
  end
end

task :build do
  puts 'building simple_approvals-chefspec'
  `gem build ./simple_approvals-chefspec.gemspec`
end

task :publish, [:version] do |_, args|
  gems = FileList.new('simple_approvals-chefspec-*.gem')
  gem_to_publish = gems.last
  gem_to_publish = "simple_approvals-chefspec-#{args[:version]}.gem" if args[:version]
  puts "publishing: #{gem_to_publish}"

  raise "cannot find '#{gem_to_publish}'" unless File.file?(gem_to_publish)

  `gem push #{gem_to_publish}`
end