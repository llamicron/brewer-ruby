# This is the helper file for rspec
# For the spec of helpers.rb, see helper_spec.b
# Code Coverage
require 'simplecov'
SimpleCov.command_name 'RSpec'
SimpleCov.start

require_relative '../lib/adaptibrew.rb'
require_relative '../lib/brewer.rb'
require_relative '../lib/helpers.rb'
require_relative '../lib/settings.rb'
