require_relative "autoload"

include Helpers

class Settings

  attr_accessor :settings
  attr_reader :cache, :source

  def initialize(testing=false)

    @source = adaptibrew_dir('settings.py')
    @cache = brewer_dir('settings.yml')

    @settings = Hash.new

    if !testing
      Adaptibrew.new.clone

      if cached_settings?
        load_cached_settings
      else
        create_parse_and_cache
      end
      load_global_variable
    end
  end

  # This will create the cache and populate
  # it with settings from settings.py
  def create_parse_and_cache
    parse_settings
    cache_settings
  end

  # Loads cached settings
  # If no cached settings, it returns false
  def load_cached_settings
    if cached_settings?
      @settings = YAML.load(File.open(@cache))
      return true
    end
    false
  end

  # Checks if there are settings in the cache
  def cached_settings?
    if File.exists?(@cache) and File.readlines(@cache).grep(/DEBUG/).size > 0
      return true
    end
    false
  end

  # Parse the settings from the source file into @settings
  def parse_settings
    File.open(@source, 'r') do |file|
      file.each_line do |line|
        if line.include? "=" and line[0] != "#"
          key, value = line.match(/(.+)=(.+)/).captures
          @settings[key.strip.chomp] = value.strip.chomp
        end
      end
      return true
    end
    false
  end

  # Creates the cache if there isn't one already
  def create_settings_cache
    unless File.exists?(@cache)
      File.open(@cache, 'w')
    end
    true
  end

  # This will add a new element to the @settings hash
  # AND re-cache the settings
  def add_setting_to_cache(setting)
    raise "Setting needs to be a hash" unless setting.is_a? Hash
    setting.each do |key, value|
      @settings[key] = value
    end
    cache_settings
  end

  # Stores the currents @settings in settings.yml
  def cache_settings
    create_settings_cache
    store = YAML::Store.new @cache
    store.transaction {
      @settings.each do |k, v|
        store[k] = v
      end
    }
    true
  end

  # This deletes the cache file
  def clear_cache
    if File.exists?(@cache)
      FileUtils.rm_f @cache
    end
    true
  end

  # This is so that the settings are easier to use in my code
  # and for backwards compatability purposes
  def load_global_variable
    create_parse_and_cache
    $settings = @settings
  end

end
