require_relative "../brewer"

# :nocov:
module Brewer
  # This class is responsible for slack communication
  class Slacker

    attr_accessor :slack, :brewer

    def initialize(webhook=false)
      @settings = Settings.new
      @brewer = Controller.new
      @slack = configure_slack(webhook)
    end

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

    def ping(message="Ping as #{Time.now}")
      if message.is_a? Array
        @slack.ping(message.join("\n"))
      else
        @slack.ping(message)
      end
    end

    def monitor(delay=10)
      while true do
        table = @brewer.status_table

        before_temp = @brewer.pv
        wait(to_seconds(delay))
        diff = @brewer.pv - before_temp

        clear_screen
        puts table

        ping([
          "Current Temperature: #{@brewer.pid['pv_temp']} F",
          "Set Value Temperature: #{@brewer.pid['sv_temp']} F",
          "Current temperature has climed #{diff} F since #{delay} minute(s) ago",
          "Sent at #{Time.now.strftime("%H:%M")}"
        ])
      end
      true
    end

  end
end
# :nocov:
