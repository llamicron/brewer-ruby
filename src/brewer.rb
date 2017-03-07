require 'date'

# NOTE: Most public methods return `self` so they can be chained together.
# This is one of the core concepts of this package.

class Brewer

  attr_reader :base_path, :out

  def initialize
    # Path of the package
    @base_path = Dir.pwd
    # Output from adaptibrew
    @out = []
    # Log file for python output
    @log = @base_path + '/logs/output'
  end

  public

  def wait(time=60)
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

  def clear
    @out = []
    self
  end

  def time
    Time.now.strftime("%d/%m/%Y %H:%M")
  end

  def write_log
    File.open(@log, 'a') do |file|
      @out.each do |out|
        file.puts "#{time}: #{out}"
      end
    end
    self
  end

  def clear_log
    File.truncate(@log, 0)
    self
  end

  def read_log
    File.open(@log, 'r') do |file|
      clear
      file.each_line do |line|
        @out.push(line)
      end
    end
    self
  end

end
