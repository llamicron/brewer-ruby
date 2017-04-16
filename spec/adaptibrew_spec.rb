require_relative 'spec_helper'

describe Brewer::Adaptibrew do

  before :each do
    @adaptibrew = Brewer::Adaptibrew.new.refresh
  end

  describe "#new" do
    specify { expect(Brewer::Adaptibrew.new).to be_an_instance_of Brewer::Adaptibrew }
  end

  describe ".clear" do
    context "when the repo exists" do
      let(:adaptibrew) { Brewer::Adaptibrew.new }
      specify { expect(adaptibrew.present?).to be true }

      it "deletes the repo" do
        @adaptibrew.clear
        expect(@adaptibrew.present?).to be false
      end
    end

    context "when the repo does not exist" do
      let(:adaptibrew) { Brewer::Adaptibrew.new }
      before { adaptibrew.clear }
      specify { expect(adaptibrew.present?).to be false }

      it "does nothing" do
        @adaptibrew.clear
        expect(@adaptibrew.present?).to be false
      end
    end
  end

  describe ".clone" do
    context "when the repo does not exist" do
      let(:adaptibrew) { Brewer::Adaptibrew.new }
      before { adaptibrew.clear }
      specify { expect(adaptibrew.present?).to be false }

      it "clones the repo" do
        @adaptibrew.clone
        expect(@adaptibrew.present?).to be true
      end
    end

    context "when the repo exists" do
      let(:adaptibrew) { Brewer::Adaptibrew.new }
      before { adaptibrew.clone }
      specify { expect(adaptibrew.present?).to be true }

      it "does nothing" do
        @adaptibrew.clone
        expect(@adaptibrew.present?).to be true
      end
    end
  end

  describe ".refresh" do
    let(:adaptibrew) { Brewer::Adaptibrew.new }
    before { adaptibrew.refresh }

    it "clears and clones the repo" do # regardless of wether or not it's there
      expect(@adaptibrew.present?).to be true
      @adaptibrew.refresh
      expect(@adaptibrew.present?).to be true
    end

  end

  describe ".present?" do
    context "when the exists" do
      let(:adaptibrew) { Brewer::Adaptibrew.new }
      before { adaptibrew.refresh }
      specify { expect(Dir.exists?(Dir.home + '/.brewer/adaptibrew')).to be true }

      it "returns true" do
        expect(@adaptibrew.present?).to be true
      end
    end

    context "when the repo does not exist" do
      let(:adaptibrew) { Brewer::Adaptibrew.new }
      before { adaptibrew.clear }
      specify { expect(Dir.exists?('adaptibrew')).to be false }
      it "returns false" do
        expect(@adaptibrew.present?).to be false
      end
    end
  end

end
