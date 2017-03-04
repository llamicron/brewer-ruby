class Brewer

  attr_reader :base_path

  def initialize
    @base_path = Dir.pwd
  end

  def wait(time=60)
    puts "Waiting for #{time} seconds"
    sleep(time)
    self
  end

  def manual_script(script, params=nil)
    return exec("python Adaptibrew/#{script}.py #{params}")
    self
  end

end
