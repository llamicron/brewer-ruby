require_relative "../brewer"

module Brewer
  class Recipe

    attr_accessor :vars

    def initialize(brewer)
      @brewer = brewer
      if !Dir.exists?(recipe_dir)
        Dir.mkdir(recipe_dir)
      end
      @vars = Hash.new(0)
    end

    def get_recipe_vars(vars=false)
      print "Enter a recipe name to load an existing recipe, or nothing to start a new one: "
      name = gets.chomp.strip

      unless name.empty?
        load_recipe(name)
        return true
      end

      if vars
        raise "Vars must be a hash" unless vars.is_a? Hash
        @vars = vars
      end

      puts Rainbow("Variables for the brew").green

      get_strike_temp

      print Rainbow("Enter mash temperature: ").yellow
      @vars['mash_temp'] = gets.chomp.to_f
      print Rainbow("Enter mash time in minutes: ").yellow
      @vars['mash_time'] = to_seconds(gets.chomp.to_f)

      print Rainbow("Enter mashout temp: ").yellow
      @vars['mashout_temp'] = gets.chomp.to_f

      true
    end

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

    def store
      print "Please enter a name for this recipe: "
      name = gets.chomp

      store = YAML::Store.new recipe_dir(name + ".yml")
      store.transaction {
        store["name"] = name
        @vars.each do |k, v|
          store[k] = v
        end
        store["created_on"] = time
      }
      return true
    end

    def load_recipe(recipe)
      raise "Recipe does not exist" unless File.exists?(recipe_dir(recipe) + ".yml")
      @vars = YAML.load(File.open(recipe_dir(recipe) + ".yml"))
      puts "Recipe Loaded"
      true
    end

    def list_recipes
      recipes = Dir.entries(recipe_dir)
      recipes.delete(".")
      recipes.delete("..")
      recipes.each do |recipe|
        recipe.slice! ".yml"
      end
      return recipes
    end

  end
end
