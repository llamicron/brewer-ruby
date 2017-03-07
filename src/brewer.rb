require 'date'

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

  # Gets the current date and time
  # Formatted as: 03/07/2017 14:26
  def time
    Time.now.strftime("%m/%d/%Y %H:%M")
  end

  # Writes contents of @out to `logs/output` with a timestamp. Example:
  # [03/07/2017 14:27]: it worked
  def write_log
    File.open(@log, 'a') do |file|
      @out.each do |out|
        file.puts "[#{time}]: #{out}"
      end
    end
    self
  end

  # Clears the @out array, which is adaptibrew output
  def clear
    write_log
    @out = []
    self
  end

  # Truncates the entire log
  def clear_log
    File.truncate(@log, 0)
    self
  end

end
