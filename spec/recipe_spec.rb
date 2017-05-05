require_relative "spec_helper"

describe Brewer::Recipe do
  before :each do
    @kitchen = Brewer::Kitchen.new
    @kitchen.recipe.vars = dummy_recipe_vars
    @kitchen.store
    @recipe = Brewer::Recipe.new("dummy_recipe")
  end

  describe "#new" do
    it "returns a new recipe object" do
      expect(Brewer::Recipe.new(blank: true)).to be_an_instance_of Brewer::Recipe
      expect(Brewer::Recipe.new("dummy_recipe")).to be_an_instance_of Brewer::Recipe
    end
  end


end
