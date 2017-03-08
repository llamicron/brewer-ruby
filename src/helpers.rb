module Helpers

  # Returns the default location for the log file.
  # A different log file is used for testing
  def log
    Dir.pwd + '/logs/output'
  end

  # Gets the current date and time
  # Formatted as: 03/07/2017 14:26
  def time
    Time.now.strftime("%m/%d/%Y %H:%M")
  end

  # Truncates the entire log
  def clear_log(log)
    File.truncate(log, 0)
  end

  # Writes each `line` element to `logs/output` with a timestamp. Example:
  # [03/07/2017 14:27]: it worked
  def write_log(log, lines)
    File.open(log, 'a') do |file|
      lines.each do |line|
        file.puts "[#{time}]: #{line}"
      end
    end
  end

end
