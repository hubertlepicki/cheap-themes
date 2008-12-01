begin
  require 'spec'
  require 'activerecord'
  require 'activesupport'
  require 'action_controller/base'
  require 'spec/rails'
rescue LoadError
  require 'rubygems'
  gem 'rspec'
  require 'spec'
  require 'activerecord'
  require 'activesupport'
  require 'action_controller/base'
  require 'spec/rails'
end

$:.unshift(File.dirname(__FILE__) + '/../lib')

plugin_spec_dir = File.dirname(__FILE__)
ActiveRecord::Base.logger = Logger.new(plugin_spec_dir + "/debug.log")

