require_relative 'spec_helper'

describe Brewer do

  before :each do
    @brewer = Brewer.new
  end

  before :all do
    Adaptibrew.new.refresh
  end

  after :all do
    # in case something goes wrong, everything needs to be reset
    @brewer.turnPumpOff
  end

  describe "#new" do
    it "returns a brewer object" do
      expect(Brewer.new).to be_an_instance_of Brewer
    end
    it "does not accept args" do
      expect { Brewer.new('heres an arg') }.to raise_exception(ArgumentError)
    end
  end

  describe ".wait" do
    # This is kind of iffy like the Helpers#time test
    it "can wait for a number of seconds" do
      #  not using let(:current_time) etc. because
      # the var is created upon the first calling, which is in the expect()
      current_time = Time.now.to_i
      @brewer.wait(1)
      expect(current_time + 1).to eq(Time.now.to_i)
    end
  end

  describe ".script" do
    it "can run a python script and get output" do
      @brewer.script('python_tester')
      expect(@brewer.out.include?("it worked")).to be true
    end
  end

  describe ".clear" do
    context "when there is output" do
      let(:brewer) { Brewer.new }
      before { brewer.script('python_tester') }
      specify { expect(brewer.out.first).to eq("it worked") }

      it "can clear the output" do
        @brewer.clear
        expect(@brewer.out).to be_empty
      end
    end
  end

  describe "set_pump" do
    # If the pump is already on it does nothing
    it "turns the pump on" do
      @brewer.set_pump('on')
      @brewer.wait(2)
      expect(@brewer.out.include?("pump on")).to be true
    end

    # If the pump is already off it does nothing
    it "turns the pump off" do
      @brewer.set_pump('off')
      expect(@brewer.out.include?("pump off")).to be true
    end
  end

  describe "set_relay" do
    it "turns the relay on" do
      @brewer.set_relay(2, 1)
      expect(@brewer.out.include?("relay 2 on"))
    end

    it "turns the relay off" do
      @brewer.set_relay(2, 0)
      expect(@brewer.out.include?("relay 2 off"))
    end
  end

end
