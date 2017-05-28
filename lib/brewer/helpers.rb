require_relative "../gems"

# Just some helper methods
module Helpers

  # Returns the current time
  # Formatted as: 03/07/2017 14:26
  def time
    Time.now.strftime("%m/%d/%Y %H:%M")
  end

  def wait(time=30)
    sleep(time.to_f)
  end

  # Returns true if there is a network connection
  # :nocov:
  def network?
    connection = Net::Ping::TCP.new('google.com', 80, 5)
    connection.ping?
  end
  # :nocov:

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
  # :nocov:
  def clear_screen
    Gem.win_platform? ? (system "cls") : (system "clear")
  end
  # :nocov:

  # Returns the path of the ~/.brewer directory, where everything is stored
  def brewer_dir(path="")
    Dir.home + "/.brewer/#{path}"
  end

  # Returns the path of the adaptibrew directory
  # ~/.brewer/adaptibrew/
  def adaptibrew_dir(path="")
    brewer_dir + "adaptibrew/#{path}"
  end

  # Returns the path of the recipe storage
  def kitchen_dir(path="")
    brewer_dir + "kitchen/#{path}"
  end

  # Captures standard output, mostly used for testing
  # :nocov:
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
  # :nocov:

  def dummy_recipe_vars
    return {
      'name' => "dummy_recipe",
      'mash_temp' => 150,
      'mash_time' => 10,
      'mashout_temp' => 172,
      'water' => 14,
      'grain' => 5,
      'grain_temp' => 80.1,
      'desired_mash_temp' => 150,
      'strike_water_temp' => 168.6,
    }
  end

  def dd(message="died here")
    puts message
    abort
  end

end
