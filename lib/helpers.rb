require 'net/ping'

module Helpers

  def log
    Dir.pwd + '/logs/output'
  end

  # Formatted as: 03/07/2017 14:26
  def time
    Time.now.strftime("%m/%d/%Y %H:%M")
  end

  def network?
    connection = Net::Ping::TCP.new('google.com', 80, 5)
    connection.ping?
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

  def confirm(input=gets.chomp)
    if ["y", "Y", "yes", "Yes", "YES", "k"].include? input
      true
    end
  end

  def ping(message="ping at #{Time.now}")
    # Required here so that you'll be asked to input webhook only
    # when you actually use slakc the first time
    require_relative 'slacker'
    $slack.ping(message)
  end

end
