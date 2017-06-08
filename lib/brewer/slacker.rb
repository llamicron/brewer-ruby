require_relative "../brewer"

# :nocov:
module Brewer
  # This class is responsible for slack communication
  class Slacker

    attr_accessor :slack, :controller

    def initialize(webhook=false)
      @controller = Controller.new
      @slack = configure_slack(webhook)
      @db = DB.new

      Brewer::load_settings
    end

    def configure_slack(webhook)
      if webhook
        return Slack::Notifier.new webhook
      end
      if !$settings['webhook_url']
        get_new_webhook
      end
      return Slack::Notifier.new $settings['webhook_url']
    end

    def get_new_webhook
      print "Slack Webhook URL: "
      webhook_url = gets.chomp
      $settings['webhook_url'] = webhook_url
      @db.update_settings
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
        table = @controller.status_table

        before_temp = @controller.pv
        wait(to_seconds(delay))
        diff = @controller.pv - before_temp

        clear_screen
        puts table

        ping([
          "Current Temperature: #{@controller.pid['pv_temp']} F",
          "Set Value Temperature: #{@controller.pid['sv_temp']} F",
          "Current temperature has climed #{diff} F since #{delay} minute(s) ago",
          "Sent at #{Time.now.strftime("%H:%M")}"
        ])
      end
      true
    end

  end
end
# :nocov:
