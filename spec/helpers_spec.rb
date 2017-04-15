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
    it "should return true" do
      expect(confirm('y')).to be true
    end
  end

  describe ".brewer_dir" do
    it "returns the .brewer directory" do
      expect(brewer_dir).to eq(Dir.home + "/.brewer/")
    end
  end

  describe ".adaptibrew_dir" do
    it "returns the .adaptibrew directory" do
      expect(adaptibrew_dir).to eq(Dir.home + "/.brewer/adaptibrew/")
    end
  end

end
