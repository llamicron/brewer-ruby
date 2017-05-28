require_relative 'spec_helper'

describe Brewer::Brewer do

  before :each do
    @brewer = Brewer::Brewer.new
  end

  before :all do
    Brewer::Adaptibrew::build
  end

  describe "#new" do
    it "returns a brewer object" do
      expect(Brewer::Brewer.new).to be_an_instance_of Brewer::Brewer
    end
    it "does not accept args" do
      expect {Brewer::Brewer.new('heres an arg')}.to raise_exception(ArgumentError)
    end
  end

  describe ".wait" do
    # This is kind of iffy like the Helpers#time test
    it "can wait for a number of seconds" do
      #  not using let(:current_time) etc. because
      # the var is created upon the first calling, which is in the expect()
      current_time = Time.now.to_i
      wait(1)
      expect(current_time + 1).to eq(Time.now.to_i)
    end
  end

  describe ".script" do
    it "can run a python script and get output" do
      expect(@brewer.script('python_tester')).to eq("it worked")
    end
  end

end
