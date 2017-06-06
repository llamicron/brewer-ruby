require_relative 'spec_helper'

describe Brewer::Controller do
  before :each do
    @controller = Brewer::Controller.new
  end

  before :all do
    Brewer::Adaptibrew::build
  end

  after :all do
    # in case something goes wrong, everything needs to be reset
    @controller = Brewer::Controller.new
    @controller.relay_config({
      'pump' => 0,
      'pid' => 0,
      'rims_to' => 'mash',
      'hlt_to' => 'mash',
      'hlt' => 0,
    })
  end

  describe ".pump" do
    # If the pump is already on it does nothing
    it "turns the pump on" do
      expect(@controller.pump(1)).to eq("pump on")
    end

    # If the pump is already off it does nothing
    it "turns the pump off" do
      expect(@controller.pump(0)).to eq("pump off")
    end

    it "returns the pump status" do
      expect(@controller.pump).to be_an_instance_of String
    end

    # cant really test this one...
    context "when the pid is also on" do
      # This turns on both pump and pid
      before { @controller.pid(1) }
      it "turns the pump and pid off" do
        expect(@controller.pump(0)).to eq("pump off")
      end
    end
  end

  describe ".relay" do
    it "turns the relay on" do
      expect(@controller.relay(2, 1)).to be true
    end

    it "turns the relay off" do
      expect(@controller.relay(2, 0)).to be true
    end
  end

  describe ".pid" do
    it "turns the pid on" do
      expect(@controller.pid(1)).to eq("Pump and PID are now on")
    end

    it "turns the pid off" do
      expect(@controller.pid(0)).to eq("PID off")
    end

    it "returns the pid status" do
      expect(@controller.pid).to be_an_instance_of Hash
    end
  end

  describe ".sv" do
    context "when there is no argument" do
      it "returns the sv temp" do
        expect(@controller.sv).to be_an_instance_of Float
      end
    end

    context "when there is an argument" do
      it "sets the sv temp" do
        expect(@controller.sv(150)).to be_an_instance_of Float
      end
    end
  end

  describe ".pv" do
    it "returns the pv" do
      expect(@controller.pv).to be_an_instance_of Float
    end
  end

  describe ".relay_status" do
    it "returns the status of a relay" do
      @controller.relay($settings['relays']['rimsToMash'], 1)
      expect(@controller.relay_status($settings['relays']['rimsToMash'].to_i)).to eq("on")
      @controller.relay($settings['relays']['rimsToMash'], 0)
      expect(@controller.relay_status($settings['relays']['rimsToMash'].to_i)).to eq("off")
    end
  end

  describe ".relays_status" do
    it "returns the status of the 4 main relays" do
      statuses = @controller.relays_status
      expect(statuses).to be_an_instance_of Hash
      expect(statuses).to_not be_empty
      expect(statuses['hlt']).to be_an_instance_of String
    end
  end

  describe ".status_table" do
    it "returns a current status table" do
      expect(@controller.status_table).to be_an_instance_of Terminal::Table
    end
  end

  describe ".relay_config" do
    it "sets the relays to the configuration" do
      @controller.relay_config({
        'hlt' => 1,
        'pump' => 0,
      })
      expect(@controller.relay_status($settings['relays']['hlt'])).to eq("on")
    end
  end

  describe ".hlt" do
    it "opens or closes the hlt valve" do
      @controller.hlt(0)
      expect(@controller.relay_status($settings['relays']['hlt'])).to eq("off")
      @controller.hlt(1)
      expect(@controller.relay_status($settings['relays']['hlt'])).to eq("on")
    end
  end

  describe ".rims_to" do
    it "diverts the rims relay to boil or mash tuns" do
      @controller.rims_to("boil")
      expect(@controller.relay_status($settings['relays']['rimsToMash'])).to eq("on")
      @controller.rims_to("mash")
      expect(@controller.relay_status($settings['relays']['rimsToMash'])).to eq("off")
    end

    context "when the location is not valid" do
      it "raises an error" do
        expect { @controller.rims_to("not_valid") }.to raise_error(/valid location/)
      end
    end
  end

  describe ".hlt_to" do
    it "diverts the hlt relay to boil or mash tuns" do
      @controller.hlt_to("boil")
      expect(@controller.relay_status($settings['relays']['hltToMash'])).to eq("on")
      @controller.hlt_to("mash")
      expect(@controller.relay_status($settings['relays']['hltToMash'])).to eq("off")
    end

    context "when the location is not valid" do
      it "raises an error" do
        expect { @controller.hlt_to("not_valid") }.to raise_error(/valid location/)
      end
    end
  end

end
