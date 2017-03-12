module Helpers

  def log
    Dir.pwd + '/logs/output'
  end

  # Formatted as: 03/07/2017 14:26
  def time
    Time.now.strftime("%m/%d/%Y %H:%M")
  end

  def clear_log(log)
    File.truncate(log, 0)
  end

  def write_log(log, lines)
    File.open(log, 'a') do |file|
      lines.each do |line|
        file.puts "[#{time}]: #{line}"
      end
    end
  end

end
