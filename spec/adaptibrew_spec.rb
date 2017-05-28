require "spec_helper"

describe Brewer::Adaptibrew do

  it "has a version number" do
    expect(Brewer::Adaptibrew::VERSION).not_to be_empty
  end

  before {
    FileUtils.rm_rf(Dir.home + "/.brewer")
  }
  
  it "can build" do
    expect(Dir.exists?(Dir.home + "/.brewer")).to be false
    expect(Brewer::Adaptibrew::build).to be true
    expect(Dir.exists?(Dir.home + "/.brewer")).to be true
  end
end
