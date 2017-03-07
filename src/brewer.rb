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

end
