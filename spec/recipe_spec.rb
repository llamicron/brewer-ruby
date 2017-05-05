require_relative "spec_helper"

describe Brewer::Recipe do
  before :each do
    @recipe = Brewer::Recipe.new
  end

  describe "#new" do
    it "returns a new recipe object" do
      expect(Brewer::Recipe.new).to be_an_instance_of Brewer::Recipe
    end
  end


end
