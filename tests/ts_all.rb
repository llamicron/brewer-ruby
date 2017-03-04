# Code Coverage
require 'simplecov'
SimpleCov.command_name 'Unit Tests'
SimpleCov.start

# Test Framework
require 'test/unit'

# Test Cases
require_relative 'tc_adaptibrew'
require_relative 'tc_brewer'
