require_relative "../brewer"

module Brewer
  # This class is responsible for slack communication
  class Slacker

    attr_accessor :slack, :brewer

    def initialize
      @settings = Settings.new
      @brewer = Brewer.new
      @slack = configure_slack
    end

    # This will look for a webhook in settings.yml and ask you for one if it doesn't find one
    def configure_slack
      unless @settings.settings['webhook_url']
        print "Slack Webhook URL: "
        webhook_url = gets.chomp
        @settings.add({
          'webhook_url' => webhook_url
        })
      end
      return Slack::Notifier.new @settings.settings['webhook_url']
    end

    # This sends a message in slack.
    # If an array is passed in, it will send it as one message with
    # new lines between each array item
    def ping(message="ping at #{Time.now}")
      @slack.ping(message)
    end

    # This does the same thing as Brewer#monitor, but it also sends a slack message
    # after a specified wait, normally 10 minutes
    def monitor(delay=10)
      while true do
        table = @brewer.status_table

        before_temp = @brewer.pv
        @brewer.wait(to_seconds(delay))
        diff = @brewer.pv - before_temp

        clear_screen
        puts table

        ping([
          "Current Temperature: #{@brewer.pid['pv_temp']} F",
          "Set Value Temperature: #{@brewer.pid['sv_temp']} F",
          "Current temperature has climed #{diff} F since #{delay} minute(s) ago",
          "Sent at #{Time.now.strftime("%H:%M")}"
        ].join("\n"))
      end
      true
    end

  end
end
