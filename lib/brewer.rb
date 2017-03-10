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
    # Path of the package
    @base_path = Dir.pwd
    # Output from adaptibrew
    @out = []
    # Log file for @out. Everything in the log file will be from @out.
    @log = @base_path + '/logs/output'
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
  # Writes current `@out` to log
  # This is why the prod log is changed when tests are run
  def clear
    write_log(@log, @out)
    @out = []
    self
  end

end
