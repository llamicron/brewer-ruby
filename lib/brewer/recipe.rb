require_relative "../brewer"

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

    puts "Variables for heating strike water"
    get_strike_temp

    puts "Variables for mash ---"
    print "Enter mash temperature: "
    @mash_temp = gets.chomp.to_f
    print "Enter mash time in minutes: "
    @mash_time = to_seconds(gets.chomp.to_f)

    puts "Variables for mashout ---"
    print "Enter mashout temp: "
    @mashout_temp = gets.chomp.to_f
  end

  def get_strike_temp
    print "Input amount of water in quarts: "
    @water = gets.chomp.to_f

    print "Input amount of grain in lbs: "
    @grain = gets.chomp.to_f

    print "Input current grain temp (#{@brewer.pv.to_s} F): "
    @grain_temp = gets.chomp.to_f
    if @grain_temp == ""
      @grain_temp = @brewer.pv
    end

    print "Input desired mash temp (150 F): "
    @desired_mash_temp = gets.chomp
    if @desired_mash_temp == ""
      @desired_mash_temp = 150
    end
    @desired_mash_temp

    @strike_water_temp = script('get_strike_temp', "#{@water} #{@grain} #{@grain_temp} #{@desired_mash_temp}").to_f
  end

end
