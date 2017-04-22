require_relative "../brewer"

module Brewer
  class Recipe

    attr_accessor :mash_temp, :mash_time, :mashout_temp, :water, :grain, :grain_temp, :desired_mash_temp, :strike_water_temp, :starting_strike_temp

    def initialize(brewer)
      @brewer = brewer
    end

    def get_recipe_vars(vars=false)
      if vars
        raise "Vars must be a hash" unless vars.is_a? Hash
        vars.each do |recipe_key, value|
          instance_variable_set("@" + recipe_key, value)
        end
      end

      puts Rainbow("Variables for the brew").green

      get_strike_temp

      print Rainbow("Enter mash temperature: ").yellow
      @mash_temp = gets.chomp.to_f
      print Rainbow("Enter mash time in minutes: ").yellow
      @mash_time = to_seconds(gets.chomp.to_f)

      print Rainbow("Enter mashout temp: ").yellow
      @mashout_temp = gets.chomp.to_f
    end

    def get_strike_temp
      print Rainbow("Input amount of water in quarts: ").yellow
      @water = gets.chomp.to_f

      print Rainbow("Input amount of grain in lbs: ").yellow
      @grain = gets.chomp.to_f

      print Rainbow("Input current grain temp (#{@brewer.pv.to_s} F): ").yellow
      @grain_temp = gets.chomp.to_f
      if @grain_temp == ""
        @grain_temp = @brewer.pv
      end

      print Rainbow("Input desired mash temp (150 F): ").yellow
      @desired_mash_temp = gets.chomp
      if @desired_mash_temp == ""
        @desired_mash_temp = 150
      end
      @desired_mash_temp

      @strike_water_temp = @brewer.script('get_strike_temp', "#{@water} #{@grain} #{@grain_temp} #{@desired_mash_temp}").to_f
    end

  end
end
