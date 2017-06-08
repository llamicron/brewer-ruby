require_relative "gems"

require_rel 'brewer/'

include Helpers
include Brewer

Brewer::Adaptibrew::build

module Brewer
  def self.load_settings
    db = Brewer::DB.new
    $settings = db.get_latest_settings.reject { |key| key.is_a? Integer }
  end

  def self.load_recipe(recipe)
    return Recipe.new(recipe: recipe)
  end
end

Brewer::load_settings
