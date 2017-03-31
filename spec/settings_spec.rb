require_relative 'spec_helper'


describe "Settings" do

  before :all do
    @adaptibrew = Adaptibrew.new
  end

  describe "settings" do
    it "can print the settings" do
      expect($settings).to be_an_instance_of Hash
      expect($settings).not_to be_empty
    end
  end

  describe "clone" do
    context "when the repo does not exist" do
      let(:adaptibrew) { Adaptibrew.new }
      before { adaptibrew.clear }
      specify { expect(adaptibrew.present?).to be false }

      it "clones the repo" do
        get_repo_for_settings(@adaptibrew)
        expect(@adaptibrew.present?).to be true
      end
    end
  end

end
