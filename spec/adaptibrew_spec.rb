require_relative 'spec_helper'

include Helpers

describe Brewer::Adaptibrew do

  before :each do
    @adaptibrew = Adaptibrew.new
    @adaptibrew.clone
  end

  after :all do
    Adaptibrew.new.clone
  end

  describe "#new" do
    it "makes a new Adaptibrew object" do
      expect(Adaptibrew.new).to be_an_instance_of Adaptibrew
    end
  end

  describe ".clear" do
    context "when the repo exists" do
      before  { @adaptibrew.clone }
      specify { expect(@adaptibrew.present?).to be true }
      it "deletes the repo and returns true" do
        expect(@adaptibrew.clear).to be true
        expect(@adaptibrew.present?).to be false
      end
    end

    context "when the repo does not exist" do
      before  { @adaptibrew.clear }
      specify { expect(@adaptibrew.present?).to be false }
      it "does nothing and returns false" do
        expect(@adaptibrew.clear).to be false
        expect(@adaptibrew.present?).to be false
      end
    end
  end

  describe ".clone" do
    context "when the repo exists" do
      before { @adaptibrew.clone }
      it "does nothing and returns false" do
        expect(@adaptibrew.clone).to be false
        expect(@adaptibrew.present?).to be true
      end
    end

    context "when the repo does not exist" do
      before { @adaptibrew.clear }
      it "clones it and returns true" do
        expect(@adaptibrew.clone).to be true
        expect(@adaptibrew.present?).to be true
      end
    end

    context "when network operations are disabled" do
      # Clearing it here so that @adaptibrew.clone would otherwise return true
      before { @adaptibrew.clear}
      before { @adaptibrew.disable_network_operations = true}
      it "does nothing and returns false" do
        expect(@adaptibrew.clone).to be false
      end
      after { @adaptibrew.disable_network_operations = false}
    end
  end

  describe ".refresh" do
    context "when network operations are disabled" do
      before { @adaptibrew.disable_network_operations = true}
      it "does nothing and returns false" do
        expect(@adaptibrew.refresh).to be false
      end
      after { @adaptibrew.disable_network_operations = false}
    end

    it "clears and clones the repo then returns true" do
      expect(@adaptibrew.refresh).to be true
    end
  end

  describe ".present?" do
    context "when the exists" do
      before { @adaptibrew.clone }
      specify { expect(Dir.exists?(adaptibrew_dir)).to be true }
      it "returns true" do
        expect(@adaptibrew.present?).to be true
      end
    end

    context "when the repo does not exist" do
      before { @adaptibrew.clear }
      specify { expect(Dir.exists?(adaptibrew_dir)).to be false }
      it "returns false" do
        expect(@adaptibrew.present?).to be false
      end
    end
  end

end
