require 'date'
require_relative 'helpers'
require_relative 'adaptibrew'

include Helpers

# This is the main brewer class.
# This contains all the methods needed to control a brew rig
# setup with adaptiman/adaptibrew.
class Brewer

  # Path to the gem root
  attr_reader :base_path

  # Output of adaptibrew
  attr_accessor :out

  def initialize
    @base_path = Dir.pwd                  # Path of the package
    @out = []                             # Output from adaptibrew
    @log = @base_path + '/logs/output'    # Log file for @out. Everything in the log file will be from @out.
  end

  public

  # Waits for `time` seconds. Pretty simple stuff.
  def wait(time=30)
    puts "Waiting for #{time} seconds"
    sleep(time)
    self
  end

  # Runs an adaptibrew script
  # Output will be stored in `@out'
  def script(script, params=nil)
    @out.unshift(`python #{@base_path}/adaptibrew/#{script}.py #{params}`.chomp)
    self
  end

  # Clears the `@out` array
  def clear
    # Write current `@out` to log
    write_log(@log, @out)
    @out = []
    self
  end

end
