require 'date'
require_relative 'helpers'

include Helpers

# NOTE: Most public methods return `self` so they can be chained together.
# This is one of the core concepts of this package.

class Brewer

  attr_reader :base_path
  attr_accessor :out

  def initialize
    @base_path = Dir.pwd                  # Path of the package
    @out = []                             # Output from adaptibrew
    @log = @base_path + '/logs/output'    # Log file for @out. Everything in the log file will be from @out.
  end

  public

  # Waits. Pretty simple stuff. `time` is seconds.
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

  # Clears the @out array, which is adaptibrew output
  def clear
    # Write current @out to log, then set it to an empty array
    write_log(@log, @out)
    @out = []
    self
  end

end
