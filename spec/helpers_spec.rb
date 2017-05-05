require_relative 'spec_helper'

include Helpers

describe "Helpers" do

  describe "#time" do
    it "can return the date/time" do
      # This might not be consistent???
      # What if the minute changes during tests?
      # dunno lol
      expect(time).to eq(Time.now.strftime("%m/%d/%Y %H:%M"))
    end
  end

  describe "#confirm" do
    context "when y is given" do
      it "should return true" do
        expect(confirm('y')).to be true
      end
    end

    context "when n is given" do
      it "should return false" do
        expect(confirm('n')).to be false
      end
    end
  end

  describe ".brewer_dir" do
    it "returns the .brewer directory" do
      expect(brewer_dir).to eq(Dir.home + "/.brewer/")
    end
  end

  describe ".kitchen_dir" do
    it "returns the path to the recipe storage dir" do
      expect(kitchen_dir).to eq(Dir.home + "/.brewer/kitchen/")
    end
  end

  describe ".adaptibrew_dir" do
    it "returns the .adaptibrew directory" do
      expect(adaptibrew_dir).to eq(Dir.home + "/.brewer/adaptibrew/")
    end
  end

  describe ".to_minutes" do
    it "turns seconds to minutes" do
      expect(to_minutes(60)).to eq(1)
    end
  end

  describe ".to_seconds" do
    it "turns minutes to seconds" do
      expect(to_seconds(1)).to eq(60)
    end
  end

  describe ".dummy_recipe_vars" do
    it "returns a hash of dummy recipe vars" do
      dummy = dummy_recipe_vars
      expect(dummy).to be_an_instance_of Hash
      expect(dummy).not_to be_empty
    end
  end

end
