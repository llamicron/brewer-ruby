require_relative "../gems"

# Just some helper methods
module Helpers

  # Returns the current time
  # Formatted as: 03/07/2017 14:26
  def time
    Time.now.strftime("%m/%d/%Y %H:%M")
  end

  # Returns true if there is a network connection
  def network?
    connection = Net::Ping::TCP.new('google.com', 80, 5)
    connection.ping?
  end

  # waits for user input, if 'y' return true, else return false
  def confirm(input=gets.chomp)
    if input.to_b
      return true
    end
    false
  end

  # Converts seconds to minutes
  def to_minutes(seconds)
    seconds.to_f / 60
  end

  # Converts minutes to seconds
  def to_seconds(minutes)
    minutes.to_f * 60
  end

  # Clears the terminal screen
  def clear_screen
    Gem.win_platform? ? (system "cls") : (system "clear")
  end

  # Returns the path of the ~/.brewer directory, where everything is stored
  def brewer_dir(path="")
    return Dir.home + "/.brewer/#{path}"
  end

  # Returns the path of the adaptibrew directory
  # ~/.brewer/adaptibrew/
  def adaptibrew_dir(path="")
    return brewer_dir + "adaptibrew/#{path}"
  end

  # Captures standard output, mostly used for testing
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
