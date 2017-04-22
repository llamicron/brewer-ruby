require_relative "../gems"

module Helpers

  # Returns the current time
  # Formatted as: 03/07/2017 14:26
  def time
    Time.now.strftime("%m/%d/%Y %H:%M")
  end

  def view(view)
    File.open(File.join(__dir__ + "/../../views/#{view}.html.erb"))
  end

  # Returns true if there is a network connection
  def network?
    connection = Net::Ping::TCP.new('google.com', 80, 5)
    connection.ping?
  end

  def confirm(input=gets.chomp)
    if input.to_b
      return true
    end
    false
  end

  def to_minutes(seconds)
    seconds.to_f / 60
  end

  def to_seconds(minutes)
    minutes.to_f * 60
  end

  def clear_screen
    Gem.win_platform? ? (system "cls") : (system "clear")
  end

  def brewer_dir(path="")
    return Dir.home + "/.brewer/#{path}"
  end

  def adaptibrew_dir(path="")
    return brewer_dir + "adaptibrew/#{path}"
  end

  def capture_stdout(&block)
    original_stdout = $stdout
    $stdout = fake = StringIO.new
    begin
      yield
    ensure
      $stdout = original_stdout
    end
    fake.string
  end

end
