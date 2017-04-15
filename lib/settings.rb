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

  def load_cached_settings
    if cached_settings?
      @settings = YAML.load(File.open(@cache))
      return true
    end
    false
  end

  def cached_settings?
    if File.exists?(@cache) and File.readlines(@cache).grep(/DEBUG/).size > 0
      return true
    end
    false
  end

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

  def create_settings_cache
    unless File.exists?(@cache)
      File.open(@cache, 'w')
    end
    true
  end

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

  def type_cast
    @settings.each do |k, v|
      # Match ints
      begin
        capture = v.match(/= ([0-9]+)/).captures
        @settings[k] = capture.strip.chomp.to_i
      rescue NoMethodError
        # Do nothing
      end

      # Match Booleans
      begin
        capture = v.match(/= ([false|true]+)/i).captures
        @settings[k] = capture.strip.chomp.to_b
      rescue NoMethodError
        # Do nothing
      end
    end
  end
end
