require_relative "../brewer"

module Brewer
  class Recipe

    attr_accessor :vars

    def initialize(name=nil, blank: false)
      @controller = Controller.new
      @db = DB.new

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

    def load(recipe_name)
      @vars = @db.get_recipe(recipe_name)
      return @vars.empty? ? false : true
    end

    def store
      @db.write_recipe(@vars)
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
      water_to_grain_ratio = @vars['water'] / @vars['grain']
      strike_water_temp = ((0.2 / water_to_grain_ratio) * (@vars['mash_temp'] - @vars['grain_temp'])) + @vars['mash_temp']
      return strike_water_temp.round
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
