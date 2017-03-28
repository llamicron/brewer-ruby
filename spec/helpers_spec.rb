require_relative 'spec_helper'

include Helpers

describe "Helpers" do

  describe "#log" do
    it "returns the log file path" do
      expect(log).to eq(Dir.pwd + '/logs/output')
    end
  end

  describe "#time" do
    it "can return the date/time" do
      # This might not be consistent???
      # What if the minute changes during tests?
      # dunno lol
      expect(time).to eq(Time.now.strftime("%m/%d/%Y %H:%M"))
    end
  end

  describe "#write_log and #clear_log" do
    context "when the log is empty" do
      before { clear_log(log) }
      specify { expect(File.zero?(log)).to be true }
      it "can write to the log" do
        write_log(log, ['log entry'])
        expect(File.zero?(log)).to be false
      end
    end

    context "when the log is not empty" do
      write_log(log, ['log entry'])
      specify { expect(File.zero?(log)).to be false }
      it "can clear the log" do
        clear_log(log)
        expect(File.zero?(log)).to be true
      end
    end
  end

  describe "#confirm" do
    it "should return true" do
      expect(confirm('y')).to be true
    end
  end

end
