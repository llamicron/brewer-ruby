require_relative "gems"

require_rel 'brewer/'

include Helpers
include Brewer

Brewer::Adaptibrew::build
