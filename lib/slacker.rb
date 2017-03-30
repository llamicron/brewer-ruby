require 'slack-notifier'
require 'yaml'
require 'yaml/store'

if !File.file?('.slack.yml')

  # this will create the file if it doesn't exists, which it doesn't in this context
  store = YAML::Store.new '.slack.yml'

  # you can get this from your slack app integrations page
  print "Enter your Slack webhook url: "
  webhook_url = gets.chomp

  # This just stores the webhook_url so you only have to enter it once
  store.transaction do
    store['webhook_url'] = webhook_url
  end

  # Here's a comment in .slack.yml so if you find it by accident you'll know what it does
  File.open(".slack.yml", 'a') do |file|
    file.puts "# This is the slack configuration file for the brewer gem"
    file.puts "# You can delete this file and brewer will re-create it on start-up"
  end
end


# finally, start up a global variable for the brewer class to use
# A full `Slacker` class is not needed, since this only does one thing
$slack = Slack::Notifier.new YAML.load(File.open('.slack.yml'))['webhook_url']
