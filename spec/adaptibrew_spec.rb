require_relative 'spec_helper'

describe Adaptibrew do

  before :each do
    @adaptibrew = Adaptibrew.new
  end

  describe "#new" do
    specify { expect(@adaptibrew).to be_an_instance_of Adaptibrew }
  end

  describe ".clear" do
    context "when the repo already exists" do
      specify { expect(Dir.exists?('adaptibrew')).to be true }

      it "deletes the repo" do
        @adaptibrew.clear
        expect(Dir.exists?('adaptibrew')).to be false
      end
    end

    context "when the repo does not exist" do
      let(:adaptibrew) { Adaptibrew.new }
      before { adaptibrew.clear }
      specify { expect(Dir.exists?('adaptibrew')).to be false }

      it "does nothing" do
        @adaptibrew.clear
        expect(Dir.exists?('adaptibrew')).to be false
      end
    end

  end

  describe ".clone" do
    context "when the repo does not exist" do
      let(:adaptibrew) { Adaptibrew.new }
      before { adaptibrew.clear }
      specify { expect(Dir.exists?('adaptibrew')).to be false }

      it "clones the repo" do
        @adaptibrew.clone
        expect(Dir.exists?('adaptibrew')).to be true
      end
    end

    context "when the repo exists" do
      let(:adaptibrew) { Adaptibrew.new }
      before { adaptibrew.clone }
      specify { expect(Dir.exists?('adaptibrew')).to be true }

      it "does nothing" do
        @adaptibrew.clone
        expect(Dir.exists?('adaptibrew')).to be true
      end
    end

  end

  describe ".refresh" do
    let(:adaptibrew) { Adaptibrew.new }
    before { adaptibrew.refresh }
    it "clears and clones the repo" do # regardless of wether or not it's there
      expect(Dir.exists?('adaptibrew')).to be true
      @adaptibrew.refresh
      expect(Dir.exists?('adaptibrew')).to be true
    end
  end

end
