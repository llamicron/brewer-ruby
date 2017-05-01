require_relative "../brewer"

module Brewer
  class Recipe

    attr_accessor :vars

    def initialize(dummy: false)
      if dummy
        @vars = dummy_recipe_vars
      else
        @vars = Hash.new(0)
      end
    end

    # These methods require a lot of user input. Not going to test them.
    # :nocov:
    def get_recipe_vars(vars=false)
      if vars
        raise "Vars must be a hash" unless vars.is_a? Hash
        @vars = vars
        return true
      end

      if !list_recipes.empty?
        clear_screen
        puts "Enter a recipe name to load an existing recipe, or nothing to start a new one."
        puts list_as_table
        print "> "
        name = gets.chomp.strip
      else
        puts Rainbow("No available recipes").yellow
        name = ""
      end

      unless name.empty?
        load(name)
        return true
      end

      puts Rainbow("Creating a new recipe").green

      get_strike_temp

      print Rainbow("Enter mash temperature: ").yellow
      @vars['mash_temp'] = gets.chomp.to_f
      print Rainbow("Enter mash time in minutes: ").yellow
      @vars['mash_time'] = to_seconds(gets.chomp.to_f)

      print Rainbow("Enter mashout temp: ").yellow
      @vars['mashout_temp'] = gets.chomp.to_f

      puts Rainbow("Enter a name for your new recipe, or nothing to not store the recipe.").yellow
      print "> "
      name = gets.chomp

      if !name.empty?
        @vars['name'] = name
        store
        puts Rainbow("Recipe saved.").green
      end
      true
    end
    # :nocov:

    # :nocov:
    def get_strike_temp
      print Rainbow("Input amount of water in quarts: ").yellow
      @vars['water'] = gets.chomp.to_f

      print Rainbow("Input amount of grain in lbs: ").yellow
      @vars['grain'] = gets.chomp.to_f

      print Rainbow("Input current grain temp (#{@brewer.pv.to_s} F): ").yellow
      @vars['grain_temp'] = gets.chomp.to_f
      if @vars['grain_temp'] == ""
        @vars['grain_temp'] = @brewer.pv
      end

      print Rainbow("Input desired mash temp (150 F): ").yellow
      @vars['desired_mash_temp'] = gets.chomp
      if @vars['desired_mash_temp'] == ""
        @vars['desired_mash_temp'] = 150
      end
      @vars['desired_mash_temp']

      @vars['strike_water_temp'] = @brewer.script('get_strike_temp', "#{@vars['water']} #{@vars['grain']} #{@vars['grain_temp']} #{@vars['desired_mash_temp']}").to_f
    end
    # :nocov:

  end
end
