require_relative "../brewer"

module Brewer
  class Recipe

    attr_accessor :vars

    def initialize(name=nil, blank: false)
      @controller = Controller.new

      @vars = {}

      if blank
        return true
      end

      if name
        load(name)
        return true
      else
        get_recipe_vars
        typecast_vars
      end
    end

    def name
      return @vars['name'] if @vars['name']
    end

    def load(recipe)
      @vars = YAML.load(File.open(kitchen_dir(recipe) + ".yml"))
    end

    # :nocov:
    def get_recipe_vars
      puts Rainbow("Creating a new recipe").green

      using_message("Name this recipe: ").ask_for("name")
      using_message("Amount of water in quarts: ").ask_for("water")
      using_message("Amount of grain in lbs: ").ask_for("grain")
      using_message("Current grain temp (#{@controller.pv.to_s} F): ").ask_for("grain_temp", default: @controller.pv)
      using_message("Desired mash temp (150 F): ").ask_for("desired_mash_temp", default: 150)
      using_message("Mash temperature: ").ask_for("mash_temp")
      using_message("Mash time in minutes (60): ").ask_for("mash_time", default: 60)
      using_message("Mashout temp: ").ask_for("mashout_temp")

      @vars['mash_time'] = to_seconds(@vars['mash_time'])
      true
    end
    # :nocov:

    # :nocov:
    def calculate_strike_temp
      @vars['strike_water_temp'] = @controller.script('get_strike_temp', "#{@vars['water']} #{@vars['grain']} #{@vars['grain_temp']} #{@vars['desired_mash_temp']}").to_f
    end
    # :nocov:

    def using_message(message)
      raise "Message needs to be a string" unless message.is_a? String
      print message
      self
    end

    def ask_for(var, default: nil)
      @vars[var] = default
      input = gets.chomp.strip
      @vars[var] = input if !input.empty?
    end

    def typecast_vars
      @vars.each do |key, value|
        # All values in @vars should be floats
        @vars[key] = value.to_f if key != "name"
      end
    end

  end
end
