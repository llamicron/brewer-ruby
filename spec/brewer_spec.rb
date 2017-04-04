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
    @brewer = Brewer.new
    @brewer.pump(0)
    @brewer.pid(0)
    @brewer.boot
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
      expect(@brewer.script('python_tester')).to eq("it worked")
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

  describe ".pump" do
    # If the pump is already on it does nothing
    it "turns the pump on" do
      expect(@brewer.pump(1)).to eq("pump on")
      @brewer.wait(2)
    end

    # If the pump is already off it does nothing
    it "turns the pump off" do
      expect(@brewer.pump(0)).to eq("pump off")
    end

    # cant really test this one...
    context "when the pid is also on" do
      # This turns on both pump and pid
      before { @brewer.pid(1) }
      it "turns the pump and pid off" do
        expect(@brewer.pump(0)).to eq("pump off")
      end
    end
  end

  describe ".relay" do
    it "turns the relay on" do
      expect(@brewer.relay(2, 1)).to eq("relay 2 on")
      @brewer.wait(7)
    end

    it "turns the relay off" do
      expect(@brewer.relay(2, 0)).to eq("relay 2 off")
      @brewer.wait(7)
    end
  end

  describe ".pid" do
    it "turns the pid on" do
      expect(@brewer.pid(1)).to eq("Pump and PID are now on")
      @brewer.wait(2)
    end

    it "turns the pid off" do
      expect(@brewer.pid(0)).to eq("PID off")
    end

    it "returns the pid status" do
      expect(@brewer.pid).to be_an_instance_of Hash
    end
  end

  describe ".sv" do
    context "when there is no argument" do
      it "returns the sv temp" do
        expect(@brewer.sv).to be_an_instance_of String
      end
    end

    context "when there is an argument" do
      it "sets the sv temp" do
        expect(@brewer.sv(150)).to be_an_instance_of String
      end
    end
  end

  describe ".pv" do
    it "returns the pv" do
      expect(@brewer.pv).to be_an_instance_of String
    end
  end

  describe ".echo" do
    context "when there is an argument" do
      it "prints the arg" do
        expect(@brewer.echo("just part of a test")).to eq("just part of a test")
      end
    end

    context "when there is no argument" do
      before { @brewer.pv }
      it "prints the last output" do
        expect(@brewer.echo).to be_an_instance_of String
      end
    end
  end

  describe ".relay_status" do
    it "returns the status of a relay" do
      expect(@brewer.relay_status($settings['rimsToMashRelay'].to_i)).not_to be_empty
    end
  end

end
