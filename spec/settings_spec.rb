require_relative 'spec_helper'


describe "Settings" do

  before :all do
    @adaptibrew = Adaptibrew.new.clone
    @settings = Settings.new(true)
  end

  describe ".load_cached_settings" do
    context "when there are cached settings" do
      before {
        @settings.parse_and_cache
        @settings.settings = {}
      }

      specify { expect(@settings.cache?).to be true }
      it "loads the cached settings" do
        @settings.load_cached_settings
        expect(@settings.settings).not_to be_empty
      end
    end

    context "when there is no settings cache" do
      before { @settings.clear_cache }

      specify { expect(@settings.cache?).to be false }
      it "returns false" do
        expect(@settings.load_cached_settings).to be false
      end
    end
  end

  describe ".cache?" do
    context "when the cache exists" do
      before {
        @settings.parse_and_cache
      }
      it "returns true" do
        expect(@settings.cache?).to be true
      end
    end

    context "when the cache does not exist" do
      before { @settings.clear_cache }

      it "returns false" do
        expect(@settings.cache?).to be false
      end
    end
  end

  describe ".parse" do
    before { @settings.settings = Hash.new }

    it "parses settings from settings.py into @settings" do
      @settings.parse
      expect(@settings.settings).not_to be_empty
    end
  end

  describe ".create_cache" do
    context "when the cache exists" do
      before { @settings.parse_and_cache }

      specify { expect(@settings.cache?).to be true }
      it "returns true" do
        expect(@settings.create_cache).to be true
      end
    end

    context "when the cache does not exist" do
      before { @settings.clear_cache }

      specify { expect(@settings.cache?).to be false }
      it "creates the cache and returns true" do
        expect(@settings.create_cache).to be true
        expect(File.exists?(@settings.cache_file)).to be true
      end
    end
  end

  describe ".add" do
    before { @settings = Settings.new }
    specify { expect(@settings.settings['test_key']).to be nil }
    it "adds a new setting to the cache" do
      @settings.add({'test_key' => 'test_value'})
      expect(@settings.settings['test_key']).to eq('test_value')
    end
  end

  describe ".cache" do
    before { @settings.clear_cache }

    specify { expect(@settings.cache?).to be false }
    it "writes @settings to the cache file" do
      @settings.parse
      @settings.cache
      expect(@settings.cache?).to be true
    end
  end

  describe ".clear_cache" do
    before { @settings.parse_and_cache}

    specify { expect(@settings.cache?).to be true }
    it "deletes the cache file" do
      @settings.clear_cache
      expect(File.exists?(@settings.cache_file)).to be false
    end
  end

  describe ".load_global" do
    it "creates a global settings variable" do
      @settings.load_global
      expect($settings).not_to be_empty
    end
  end

end
