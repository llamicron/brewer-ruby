require_relative 'helpers'
require_relative 'adaptibrew'

include Helpers

class Brewer

  attr_reader :base_path
  attr_accessor :out, :log

  def initialize
    @base_path = Dir.pwd
    # Output of adaptibrew
    @out = []
    @log = @base_path + '/logs/output'
  end

  public

  def wait(time=30)
    puts "Waiting for #{time} seconds"
    sleep(time)
    self
  end

  # Runs an adaptibrew script
  # Output will be stored in @out
  def script(script, params=nil)
    @out.unshift(`python #{@base_path}/adaptibrew/#{script}.py #{params}`.chomp)
    self
  end

  # Clears the @out array
  # Writes current @out to log
  # This is why the prod log is changed when tests are run
  def clear
    write_log(@log, @out)
    @out = []
    self
  end

end
