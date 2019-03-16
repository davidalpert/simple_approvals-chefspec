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
