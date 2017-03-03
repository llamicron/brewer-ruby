class Brewer

  attr_reader :base_path

  def initialize
    @base_path = Dir.pwd + "/"
  end

  def heat(ton)
    puts "You gotta heat the #{ton} ton manually, dude."
  end

  def manual_script(script, params=nil)
    return exec("python Adaptibrew/#{script}.py #{params}")
  end

end
