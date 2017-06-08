require_relative "gems"

require_rel 'brewer/'

include Helpers
include Brewer

Brewer::Adaptibrew::build

module Brewer
  def self.load_settings
    db = Brewer::DB.new
    # Oh, the things i do for backwards compatibility
    settings = db.get_latest_settings.reject { |key| key.is_a? Integer }
    relays = settings.select { |key| key.match(/hlt|rimsT|pump/) }
    settings.keep_if { |key| !key.match(/hlt|rimsT|pump/) }
    settings['relays'] = relays
    $settings = settings
  end
end

Brewer::load_settings

# {
#  "id"=>1,
#  "port"=>"/dev/ttyAMA0",
#  "rimsAddress"=>1,
#  "switchAddress"=>2,
#  "baudRate"=>19200,
#  "timeout"=>2,
#  "MA0"=>"55",
#  "MA1"=>"AA",
#  "MAE"=>"77",
#  "CN"=>"02",
#  "hltToMash"=>0,
#  "hlt"=>1,
#  "rimsToMash"=>2,
#  "pump"=>3,
#  "DEBUG"=>0
# }
