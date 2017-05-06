require_relative 'spec_helper'

describe Kitchen do
  before :each do
    @kitchen = Brewer::Kitchen.new
  end

  describe "#new" do
    it "returns a kitchen object" do
      expect(Brewer::Kitchen.new).to be_an_instance_of Brewer::Kitchen
    end
  end

  describe ".present?" do
    context "when the kitchen is there" do
      before { @kitchen.clone }
      it "returns true" do
        expect(@kitchen.present?).to be true
      end
    end

    context "when the kitchen is not there" do
      before { @kitchen.clear }
      it "returns false" do
        expect(@kitchen.present?).to be false
      end
    end
  end

  describe ".clone" do
    context "when the kitchen is not there" do
      before { @kitchen.clear }
      specify { expect(@kitchen.present?).to be false }
      it "clones it" do
        @kitchen.clone
        expect(@kitchen.present?).to be true
      end
    end

    context "when the kitchen is there" do
      before { @kitchen.clone }
      specify { expect(@kitchen.present?).to be true }
      it "does nothing" do
        expect(@kitchen.clone).to be false
        expect(@kitchen.present?).to be true
      end
    end
  end

  describe ".clone" do
    context "when the kitchen is there" do
      before { @kitchen.clone }
      specify { expect(@kitchen.present?).to be true }
      it "returns false" do
        expect(@kitchen.clone).to be false
        expect(@kitchen.present?).to be true
      end
    end

    context "when the kitchen is not there" do
      before { @kitchen.clear }
      specify{ expect(@kitchen.present?).to be false }
      it "clones the kitchen and returns true" do
        expect(@kitchen.clone).to be true
        expect(@kitchen.present?).to be true
      end
    end
  end

  describe ".list_recipes" do
    it "returns an array of recipes" do
      expect(@kitchen.list_recipes).to be_an_instance_of Array
    end
  end

  describe ".list_recipes_as_table" do
    context "when the recipe list is empty" do
      before {
        @kitchen.clear
        # Need an empty directory
        Dir.mkdir(kitchen_dir)
      }
      it "returns a message" do
        capture_stdout { expect(@kitchen.list_recipes_as_table).to eq("No Saved Recipes") }
      end
    end

    context "when the recipe list is not empty" do
      before { @kitchen.refresh }
      it "returns a TerminalTable of the recipes" do
        capture_stdout { expect(@kitchen.list_recipes_as_table).to be true }
      end
    end
  end

  describe ".refresh" do
    before { @kitchen.clone }
    it "clears and clones the repo" do
      expect(@kitchen.present?).to be true
      expect(@kitchen.refresh).to be true
      expect(@kitchen.present?).to be true
    end
  end

  describe ".load" do
    before { @kitchen.clone }
    specify { expect(@kitchen.recipe_exists?("dummy_recipe")).to be true }
    it "loads a recipe into the @recipe variable" do
      expect(@kitchen.load("dummy_recipe")).to be true
      expect(@kitchen.recipe).to be_an_instance_of Recipe
    end
  end

  describe ".store" do
    context "when a recipe is loaded" do
      before {
        @kitchen.recipe = Recipe.new(blank: true)
        @kitchen.recipe.vars['name'] = "test_recipe"
      }
      it "stores the recipe" do
        expect(@kitchen.store).to be true
      end
    end
  end

  describe ".recipe_exists?" do
    context "when the recipe exists" do
      before {
        @kitchen.recipe = Brewer::Recipe.new(blank: true)
        @kitchen.recipe.vars['name'] = "test_recipe"
        @kitchen.store
      }
      it "returns true" do
        expect(@kitchen.recipe_exists?("test_recipe")).to be true
      end
    end

    context "when the recipe does not exist" do
      it "returns false" do
        expect(@kitchen.recipe_exists?("doesnt_exist")).to be false
      end
    end
  end

  describe ".loaded_recipe?" do
    context "when there is a loaded recipe" do
      before {
        @kitchen.recipe = Brewer::Recipe.new(blank: true)
        @kitchen.recipe.vars = dummy_recipe_vars
      }
      it "returns true" do
        expect(@kitchen.load("dummy_recipe")).to be true
        expect(@kitchen.loaded_recipe?).to be true
      end
    end

    context "when there is not loaded recipe" do
      before { @kitchen.recipe = nil }
      it "returns false" do
        expect(@kitchen.loaded_recipe?).to be false
      end
    end
  end

  describe ".delete_recipe" do
    it "deletes a recipe" do
      expect(@kitchen.recipe_exists?("dummy_recipe")).to be true
      expect(@kitchen.delete_recipe("dummy_recipe")).to be true
      expect(@kitchen.recipe_exists?("dummy_recipe")).to be false
    end
  end

end
