require 'slack-notifier'
require 'yaml'
require 'yaml/store'

if !File.file?('slack.yml')
  store = YAML::Store.new 'slack.yml'

  print "Enter your webhook url: "
  webhook_url = gets.chomp

  store.transaction do
    store['webhook_url'] = webhook_url
  end
end

notifier = Slack::Notifier.new YAML.load(File.open('slack.yml'))['webhook_url']



# class Slacker
#   def initialize
#     if !File.file?('slack.yml')
#       setup
#     end
#
#     notifier = Slack::Notifier.new "WEBHOOK_URL"
#
#     # Slack.configure do |config|
#     #   config.token = YAML.load(File.open('slack.yml'))['config_token']
#     # end
#     #
#     client = Slack::Web::Client.new
#     client.auth_test
#   end
#
#   def setup
#     print "Enter your slack config token: "
#     config_token = gets.chomp
#     store = YAML::Store.new "slack.yml"
#     store.transaction do
#       store['config_token'] = config_token
#     end
#   end
#
#   def send
#
#   end
#
# end
