# Code Coverage
require 'simplecov'
SimpleCov.command_name 'RSpec'
SimpleCov.start

require_relative '../lib/adaptibrew.rb'
require_relative '../lib/brewer.rb'
require_relative '../lib/helpers.rb'

include Helpers
