require_relative "spec_helper"
require 'fileutils'

include Helpers

describe Recipe do
  before :each do
    @brewer = Brewer::Brewer.new
    @recipe = Brewer::Recipe.new(@brewer)
    @recipe.new_dummy
  end

  describe "#new" do
    it "returns a new recipe object" do
      expect(Brewer::Recipe.new(@brewer)).to be_an_instance_of Brewer::Recipe
    end
  end

  describe ".new_dummy" do
    before { @recipe.clear }
    it "returns a new dummy recipe" do
      expect(@recipe.vars).to be_empty
      @recipe.new_dummy
      expect(@recipe.vars).not_to be_empty
      expect(@recipe.vars['name']).to eq("dummy_recipe")
    end
  end

  describe ".make_recipe_dir" do
    before  { FileUtils.rm_rf(recipe_dir) }
    specify { !Dir.exists?(recipe_dir)    }
    it "makes the recipe storage directory" do
      expect(@recipe.make_recipe_dir).to be true
    end
    specify { Dir.exists?(recipe_dir) }
  end

  describe ".store" do

  end

end
