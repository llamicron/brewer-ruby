require 'slack-notifier'
require 'yaml'
require 'yaml/store'

class Communicator

  attr_accessor :slack, :brewer

  def initialize
    @slack = configure_slack
    @brewer = Brewer.new
  end

  def configure_slack
    slack_file = Dir.home + "/.brewer/.slack.yml"
    if !File.file?(slack_file)
      store = YAML::Store.new slack_file
      print "Enter your Slack webhook url: "
      webhook_url = gets.chomp
      store.transaction { store['webhook_url'] = webhook_url }
    end
    return Slack::Notifier.new YAML.load(File.open(slack_file))['webhook_url']
  end

  def ping(message="ping at #{Time.now}")
    # Required here so that you'll be asked to input webhook only
    # when you actually use slakc the first time
    @slack.ping(message)
  end

  def monitor
    while true do
      before_temp = @brewer.pv.to_i
      @brewer.wait(600)
      diff = @brewer.pv.to_i - before_temp
      ping("Current Temperature: #{@brewer.pid['pv_temp']} F")
      ping("Set Value Temperature: #{@brewer.pid['sv_temp']} F")
      ping("Current temperature has climed #{diff} F since 10 minutes ago")
    end
    true
  end

end
