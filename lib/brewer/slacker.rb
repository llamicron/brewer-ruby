require_relative "../brewer"
# :nocov:
module Brewer
  # This class is responsible for slack communication
  class Slacker

    attr_accessor :slack, :brewer

    def initialize(webhook=false)
      @settings = Settings.new
      @brewer = Brewer.new
      @slack = configure_slack(webhook)
    end

    # This will look for a webhook in settings.yml and ask you for one if it doesn't find one
    def configure_slack(webhook)
      if webhook
        return Slack::Notifier.new webhook
      end
      if !@settings.settings['webhook_url']
        get_new_webhook
      end
      return Slack::Notifier.new @settings.settings['webhook_url']
    end

    def get_new_webhook
      print "Slack Webhook URL: "
      webhook_url = gets.chomp
      @settings.add({
        'webhook_url' => webhook_url
      })
      @settings.cache
      webhook_url
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
# :nocov:
