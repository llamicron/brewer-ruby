require_relative "adaptibrew"

module Brewer
  class Settings

    attr_accessor :settings
    attr_reader :cache_file, :source

    def initialize(testing=false)

      @source = adaptibrew_dir('settings.py')
      @cache_file = brewer_dir('settings.yml')

      @settings = Hash.new

      if !testing
        Adaptibrew.new.clone

        unless cache?
          parse_and_cache
        else
          load_cached_settings
        end

        load_global
      end
    end

    # This will create the cache and populate
    # it with settings from settings.py
    def parse_and_cache
      parse
      cache
    end

    # Loads cached settings
    # If no cached settings, it returns false
    def load_cached_settings
      if cache?
        @settings = YAML.load(File.open(@cache_file))
        return true
      end
      false
    end

    # Checks if there are settings in the cache
    def cache?
      if File.exists?(@cache_file) and File.readlines(@cache_file).grep(/DEBUG/).size > 0
        return true
      end
      false
    end

    # Parse the settings from the source file into @settings
    def parse
      File.open(@source, 'r') do |file|
        file.each_line do |line|
          if line.include? "=" and line[0] != "#"
            key, value = line.match(/(.+)=(.+)/).captures
            @settings[key.strip.chomp] = value.strip.chomp
          end
        end
        type_cast
        return true
      end
      false
    end

    # Creates the cache if there isn't one already
    def create_cache
      unless File.exists?(@cache_file)
        File.open(@cache_file, 'w')
      end
      true
    end

    # This will add a new element to the @settings hash
    # AND re-cache the settings
    def add(setting)
      raise "Setting needs to be a hash" unless setting.is_a? Hash
      setting.each do |key, value|
        @settings[key] = value
      end
      cache
    end

    # Stores the currents @settings in settings.yml
    def cache
      create_cache
      store = YAML::Store.new @cache_file
      store.transaction {
        @settings.each do |k, v|
          store[k] = v
        end
      }
      true
    end

    # This deletes the cache file
    def clear_cache
      if File.exists?(@cache_file)
        FileUtils.rm_f @cache_file
      end
      true
    end

    # This is so that the settings are easier to use in my code
    # and for backwards compatability purposes
    def load_global
      parse_and_cache
      $settings = @settings
    end

    def change(values)
      raise "Values to change must be a hash" unless values.is_a? Hash
      values.each do |k, v|
        @settings[k] = v
      end
      return true
    end

    # This method is r/badcode, i know
    def type_cast
      # Super janky
      change({
        'rimsaddressint' => @settings['rimsaddressint'].to_i,
        'switchaddressint' => @settings['switchaddressint'].to_i,
        'baudrate' => @settings['baudrate'].to_i,
        'timeout' => @settings['timeout'].to_i,
        'spargeToMashRelay' => @settings['spargeToMashRelay'].to_i,
        'spargeRelay' => @settings['spargeRelay'].to_i,
        'rimsToMashRelay' => @settings['rimsToMashRelay'].to_i,
        'pumpRelay' => @settings['pumpRelay'].to_i,
        'DEBUG' => @settings['DEBUG'].to_b,
      })
    end

  end
end
