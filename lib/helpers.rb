require_relative "autoload"

module Helpers

  # Formatted as: 03/07/2017 14:26
  def time
    Time.now.strftime("%m/%d/%Y %H:%M")
  end

  def network?
    connection = Net::Ping::TCP.new('google.com', 80, 5)
    connection.ping?
  end

  def confirm(input=gets.chomp)
    if ["y", "Y", "yes", "Yes", "YES", "k"].include? input
      true
    end
  end

  def to_minutes(seconds)
    seconds.to_f / 60
  end

  def to_seconds(minutes)
    minutes.to_f * 60
  end

end
