require_relative 'spec_helper'

describe Brewer::Controller do

  before :each do
    @controller = Brewer::Controller.new
  end

  before :all do
    Brewer::Adaptibrew::build
  end

  describe "#new" do
    it "returns a brewer object" do
      expect(Brewer::Controller.new).to be_an_instance_of Brewer::Controller
    end
    it "does not accept args" do
      expect {Brewer::Controller.new('heres an arg')}.to raise_exception(ArgumentError)
    end
  end

  describe ".wait" do
    # This is kind of iffy like the Helpers#time test
    it "can wait for a number of seconds" do
      current_time = Time.now.to_i
      wait(1)
      expect(current_time + 1).to eq(Time.now.to_i)
    end
  end

  describe ".script" do
    it "can run a python script and get output" do
      expect(@controller.script('python_tester')).to eq("it worked")
    end
  end

end