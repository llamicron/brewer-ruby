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

  describe ".make_kitchen_dir" do
    before  { FileUtils.rm_rf(kitchen_dir) }
    specify { !Dir.exists?(kitchen_dir)    }
    it "makes the recipe storage directory" do
      expect(@recipe.make_kitchen_dir).to be true
    end
    specify { Dir.exists?(kitchen_dir) }
  end

  describe ".store" do
    context "when there is a loaded recipe" do
      before { @recipe.delete_recipe_file }
      it "stores the loaded recipe" do
        expect(@recipe.loaded_recipe?).to be false
        @recipe.store
        expect(@recipe.loaded_recipe?).to be true
      end
    end

    context "when there is no loaded recipe" do
      before { @recipe.clear }
      specify { expect(@recipe.vars).to be_empty }
      it "raises an exception" do
        expect { @recipe.store }.to raise_error(/store/)
      end
    end
  end

  describe ".load" do
    context "when the recipe exists" do
      before { @recipe.clear }
      it "loads the recipe" do
        capture_stdout { expect(@recipe.load("dummy_recipe")).to be true }
        expect(@recipe.loaded_recipe?).to be true
      end
    end

    context "when the recipe does not exist" do
      it "raises an error" do
        expect { @recipe.load("not_a_real_recipe") }.to raise_error(/does not exist/)
      end
    end
  end

  describe ".list_recipes" do
    it "returns an array of recipes" do
      expect(@recipe.list_recipes).to be_an_instance_of Array
      expect(@recipe.list_recipes).not_to be_empty
    end
  end

  describe ".list_as_table" do
    context "when there are no recipes" do
      before { FileUtils.rm_rf(Dir.glob(kitchen_dir("*"))) }
      it "returns without a table" do
        expect(@recipe.list_as_table).to eq("No Saved Recipes.")
      end
    end

    context "when there are recipes" do
      before {
        @recipe.new_dummy
        @recipe.store
      }
      it "returns a TerminalTable" do
        expect(@recipe.list_as_table).to be_an_instance_of Terminal::Table
      end
    end
  end

end
