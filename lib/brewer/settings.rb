module Brewer
  class Settings

    attr_accessor :settings
    attr_reader :cache_file, :source_file

    def initialize(source_file: false, cache_file: false)

      @settings = {}
      @source_file = source_file ? adaptibrew_dir(source_file) : adaptibrew_dir("print_settings.py")
      @cache_file = cache_file ? brewer_dir(cache_file) : brewer_dir("settings.yml")

      if cache?
        load_cached_settings
      else
        parse
        cache
      end

      load_global
    end

    # Checks if there are settings in the cache
    def cache?
      if File.exists?(@cache_file) and File.readlines(@cache_file).grep(/DEBUG/).size > 0
        return true
      end
      false
    end

    # Parse the settings from @source_file into @settings
    def parse
      settings_file_output = `python #{@source_file}`.chomp
      settings_file_output.split("\n").each do |setting|
        key, value = setting.match(/(.+)=(.+)/).captures
        @settings[key.strip.chomp] = value.strip.chomp
      end
      true
    end

    # Creates the cache if there isn't one already
    def create_cache
      File.open(@cache_file, 'w')
      true
    end

    # Stores the currents @settings in settings.yml
    def cache
      raise "Settings cache could not be created. Check permissions on ~/.brewer/" unless create_cache
      store(@settings)
      true
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

    # This will add a new element to the @settings hash
    # AND re-cache the settings
    def add(setting)
      raise "Setting needs to be a hash" unless setting.is_a? Hash
      setting.each do |key, value|
        @settings[key] = value
      end
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
      raise "settings instance variable does not exist yet. Run Settings#parse first" unless !@settings.empty?
      type_cast
      $settings = @settings
    end

    def change(values)
      raise "Values to change must be a hash" unless values.is_a? Hash
      values.each do |k, v|
        @settings[k] = v
      end
      return true
    end

    private

    # This method is r/badcode, i know
    def type_cast
      # Super janky
      change({
        'rimsAddress' => @settings['rimsAddress'].to_i,
        'switchAddress' => @settings['switchAddress'].to_i,
        'baudRate' => @settings['baudRate'].to_i,
        'timeout' => @settings['timeout'].to_i,
        'hltToMash' => @settings['hltToMash'].to_i,
        'hlt' => @settings['hlt'].to_i,
        'rimsToMash' => @settings['rimsToMash'].to_i,
        'pump' => @settings['pump'].to_i,
        'DEBUG' => @settings['DEBUG'].to_b,
      })
    end

    # This writes directly to the @cache_file file
    def store(settings={})
      raise "You must provide a hash to store" if settings.empty?
      store = YAML::Store.new @cache_file
      store.transaction {
        settings.each do |setting, value|
          store[setting] = value
        end
      }
    end

  end
end


module Brewer
  def self.load_settings
    settings = Settings.new
    if !settings.cache?
      settings.parse
      settings.cache
    else
      settings.load_cached_settings
    end
    settings.load_global
  end
end
