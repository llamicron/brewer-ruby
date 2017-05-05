require_relative "spec_helper"
require 'fileutils'

include Helpers

describe Recipe do
  before :each do
    @brewer = Brewer::Brewer.new
    @recipe = Brewer::Recipe.new(@brewer)
    @recipe.new_dummy
    @recipe.store
  end

  describe "#new" do
    it "returns a new recipe object" do
      expect(Brewer::Recipe.new).to be_an_instance_of Brewer::Recipe
    end
  end


end
