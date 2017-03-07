# Code Coverage
require 'simplecov'
SimpleCov.command_name 'Unit Tests'
SimpleCov.start

require_relative '../src/helpers'
include Helpers

# Test Framework
require 'test/unit'

# Test Cases
require_relative 'tc_adaptibrew'
require_relative 'tc_brewer'
require_relative 'tc_helpers'
