require_relative "../brewer"

module Brewer
  class Recipe

    attr_accessor :vars

    def initialize
      # @brewer = brewer
      @vars = Hash.new(0)
    end

    def new_dummy
      @vars = dummy_recipe_vars
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

    def store(name=false)
      raise "Nothing to store! Please run `.get_recipe_vars` to fill in the recipe variables before storing." unless !@vars.empty?

      # :nocov:
      if @vars['name'].empty?
        if !name
          print "Please enter a name for this recipe: "
          @vars['name'] = gets.chomp
        else
          @vars['name'] = name
        end
      end
      # :nocov:

      store = YAML::Store.new kitchen_dir(@vars['name'] + ".yml")
      store.transaction {
        store["name"] = @vars['name']
        @vars.each do |k, v|
          store[k] = v
        end
        store["created_on"] = time
      }
      true
    end

    def list_recipes
      recipes = Dir.entries(kitchen_dir)
      recipes.delete(".")
      recipes.delete("..")
      recipes.each do |recipe|
        recipe.slice! ".yml"
      end
      recipes
    end

    def list_as_table
      if list_recipes.empty?
        return "No Saved Recipes."
      end
      recipes_table_rows = list_recipes.each_slice(5).to_a
      recipes_table = Terminal::Table.new :title => "All Recipes", :rows => recipes_table_rows
      return recipes_table
    end

    def loaded_recipe?
      if File.exists?(kitchen_dir(@vars['name']) + ".yml")
        return true
      end
      false
    end

    def clear
      @vars = {}
    end

    def delete_recipe_file
      FileUtils.rm_rf(kitchen_dir + @vars['name'] + ".yml")
      true
    end

  end
end
