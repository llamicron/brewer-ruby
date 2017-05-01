require_relative "../brewer"

module Brewer
  class Recipe

    attr_accessor :vars

    def initialize(name=nil, dummy: false, empty: false)
      if empty
        @vars = {}
        return truee
      end

      if dummy
        @vars = dummy_recipe_vars
      else
        @vars = Hash.new(0)
        @vars['name'] = name
        get_recipe_vars
      end
    end


    # :nocov:
    def get_recipe_vars
      puts Rainbow("Creating a new recipe").green

      calculate_strike_temp

      print Rainbow("Enter mash temperature: ").yellow
      @vars['mash_temp'] = gets.chomp.to_f
      print Rainbow("Enter mash time in minutes: ").yellow
      @vars['mash_time'] = to_seconds(gets.chomp.to_f)

      print Rainbow("Enter mashout temp: ").yellow
      @vars['mashout_temp'] = gets.chomp.to_f

      true
    end
    # :nocov:

    # :nocov:
    def calculate_strike_temp
      print Rainbow("Input amount of water in quarts: ").yellow
      @vars['water'] = gets.chomp.to_f

      print Rainbow("Input amount of grain in lbs: ").yellow
      @vars['grain'] = gets.chomp.to_f

      print Rainbow("Input current grain temp (#{Brewer.new.pv.to_s} F): ").yellow
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

      @vars['strike_water_temp'] = Brewer.new.script('get_strike_temp', "#{@vars['water']} #{@vars['grain']} #{@vars['grain_temp']} #{@vars['desired_mash_temp']}").to_f
    end
    # :nocov:

  end
end
