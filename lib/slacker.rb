require 'slack-notifier'
require 'yaml'
require 'yaml/store'

slack_file = Dir.home + "/.brewer/.slack.yml"

if !File.file?(slack_file)

  # this will create the file if it doesn't exists, which it doesn't in this context
  store = YAML::Store.new slack_file

  # you can get this from your slack app integrations page
  print "Enter your Slack webhook url: "
  webhook_url = gets.chomp

  # This just stores the webhook_url so you only have to enter it once
  store.transaction do
    store['webhook_url'] = webhook_url
  end
end


# finally, start up a global variable for the brewer class to use
# A full `Slacker` class is not needed, since this only does one thing
$slack = Slack::Notifier.new YAML.load(File.open(slack_file))['webhook_url']
