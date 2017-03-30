require 'slack-notifier'
require 'yaml'
require 'yaml/store'

if !File.file?('slack.yml')
  store = YAML::Store.new 'slack.yml'

  print "Enter your Slack webhook url: "
  webhook_url = gets.chomp

  store.transaction do
    store['webhook_url'] = webhook_url
  end
end

$slack = Slack::Notifier.new YAML.load(File.open('slack.yml'))['webhook_url']
