require 'pry'
require 'require_all'
require 'git'
require 'fileutils'
# `slack-notifier` version 2.2 is currently broken. These lines fix it,
# but I am using 2.1 in my gebremspec until it gets patched.
#
# module Slack; end
# class Slack::Notifier; end

require 'slack-notifier'
require 'yaml'
require 'yaml/store'
require 'net/ping'
require 'wannabe_bool'
require 'terminal-table'
require 'rainbow'
require 'brewer/adaptibrew'
