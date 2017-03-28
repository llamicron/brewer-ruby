require_relative 'spec_helper'

describe Adaptibrew do

  before :each do
    @adaptibrew = Adaptibrew.new
  end

  describe "#new" do
    it "returns a new adaptibrew object" do
      expect(@adaptibrew).to be_an_instance_of Adaptibrew
    end
  end


end
