require 'date'

class Brewer

  attr_reader :base_path, :out

  def initialize
    @base_path = Dir.pwd
    # Output from adaptibrew
    @out = {}
  end

  public

  def wait(time=60)
    puts "Waiting for #{time} seconds"
    sleep(time)
    self
  end

  # Runs an adaptibrew script
  def script(script, params=nil)
    @out[current_time] = `python #{@base_path}/adaptibrew/#{script}.py #{params}`.chomp
    self
  end

  private

  def current_time
    Time.now.strftime("%d/%m/%y %H:%M")
  end

end
