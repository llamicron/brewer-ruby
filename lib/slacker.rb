require 'slack-notifier'
require 'yaml'
require 'yaml/store'

if !File.file?('.slack.yml')
  store = YAML::Store.new '.slack.yml'

  print "Enter your Slack webhook url: "
  webhook_url = gets.chomp

  store.transaction do
    store['webhook_url'] = webhook_url
  end
end

File.open(".slack.yml", 'a') do |file|
  file.puts "# This is the slack configuration file for the brewer gem"
  file.puts "# You can delete this file and brewer will re-create it on start-up"
end

$slack = Slack::Notifier.new YAML.load(File.open('.slack.yml'))['webhook_url']
