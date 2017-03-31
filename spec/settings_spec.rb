require_relative 'spec_helper'


describe "Settings" do

  before :all do
    Adaptibrew.new.clear
  end

  describe "settings" do
    it "can print the settings" do
      expect($settings).to be_an_instance_of Hash
      expect($settings).not_to be_empty
    end
  end

end
