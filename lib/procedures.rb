require_relative 'brewer'
require_relative 'helpers'
require_relative 'communicator'

include Helpers

class Procedures

  attr_accessor :com, :brewer, :recipe

  def initialize
    @brewer = Brewer.new
    @com = Communicator.new
    @recipe = {}
  end

  def get_recipe_vars
    puts "Variables for heating strike water ---"
    get_strike_temp

    puts "Variables for mash ---"
    print "Enter mash temperature: "
    @recipe['mash_temp'] = gets.chomp.to_f
    print "Enter mash time in minutes: "
    @recipe['mash_time'] = to_seconds(gets.chomp.to_f)

    puts "Variables for mashout ---"
    print "Enter mashout temp: "
    @recipe['mashout_temp'] = gets.chomp.to_f
  end

  def get_strike_temp
    print "Input amount of water in quarts: "
    @recipe['water'] = gets.chomp.to_f

    print "Input amount of grain in lbs: "
    @recipe['grain'] = gets.chomp.to_f

    print "Input current grain temp (#{pv.to_s} F): "
    @recipe['grain_temp'] = gets.chomp.to_f
    if @recipe['grain_temp'] == ""
      @recipe['grain_temp'] = pv
    end

    print "Input desired mash temp (150 F): "
    @recipe['desired_mash_temp'] = gets.chomp
    if @recipe['desired_mash_temp'] == ""
      @recipe['desired_mash_temp'] = 150
    end
    @recipe['desired_mash_temp']

    @recipe['strike_water_temp'] = script('get_strike_temp', "#{water} #{grain} #{grain_temp} #{@recipe['desired_mash_temp']}").to_f
  end

  def master
    get_recipe_vars
    boot
    heat_strike_water
    dough_in
    mash
    mashout
    sparge
    top_off
    boil
  end

  def boot
    puts "booting..."
    @brewer.pid(0)
    @brewer.pump(0)
    @brewer.rims_to('mash')
    @brewer.hlt_to('mash')
    @brewer.all_relays_status
    puts @brewer.pid

    @brewer.clear
    puts "Boot successful!"
    @brewer.out.unshift("successful boot at #{Time.now}")
    @com.ping("🍺 boot successful 🍺")
    true
  end

  # :nocov:
  def heat_strike_water
    puts "heat-strike-water procedure started"

    # Confirm strike water is in the mash tun
    print "Is the strike water in the mash tun? "
    # -> response
    confirm ? nil : abort

    # confirm return manifold is in the mash tun
    print "Is the return manifold in the mash tun? "
    # -> response
    confirm ? nil : abort

    print "Is the mash tun valve open? "
    confirm ? nil : abort

    # confirm RIMS relay is on
    @brewer.rims_to('mash')
    puts "RIMS-to-mash relay is now on"

    # turn on pump
    @brewer.pump(1)
    puts "Pump is now on"

    puts "Is the pump running properly? "
    until confirm
      puts "restarting pump"
      @brewer.pump(0)
      @brewer.wait(2)
      @brewer.pump(1)
    end

    # confirm that strike water is circulating well
    print "Is the strike water circulating well? "
    # -> response
    confirm ? nil : abort


    # calculate strike temp & set PID to strike temp
    # this sets PID SV to calculated strike temp automagically
    @brewer.sv(@recipe['strike_water_temp'])
    puts "SV has been set to calculated strike water temp"
    # turn on RIMS heater
    @brewer.pid(1)

    # measure current strike water temp and save
    @recipe['starting_strike_temp'] = @brewer.pv
    puts "current strike water temp is #{@brewer.pv}. Saved."
    puts "Heating to #{@brewer.sv}"

    @com.ping("Strike water beginning to heat. This may take a few minutes.")

    # when strike temp is reached, @com.ping slack
    @brewer.watch
    @com.ping("Strike water heated to #{@brewer.pv}. Maintaining temperature.")
    @com.ping("Next step: dough in")
    puts "Next step: dough in"
    puts "command: brewer.dough_in"

    true
  end
  # :nocov:

  def dough_in
    # turn pump off
    @brewer.pump(0)
    # turn PID off
    @brewer.pid(0)
    @brewer.wait(3)
    @com.ping("Ready to dough in")
    puts "Ready to dough in"

    # pour in grain

    print "Confirm when you're done with dough-in (y): "
    confirm ? nil : abort
    true
  end

  def mash
    @brewer.sv(@recipe['mash_temp'])

    puts "mash stated. This will take a while."
    @com.ping("Mash started. This will take a while.")

    @brewer.rims_to('mash')

    @brewer.pump(1)
    @brewer.pid(1)

    @brewer.watch
    @com.ping("Mash temp (#{@brewer.pv} F) reached. Starting timer for #{@recipe['mash_time']} minutes.")
    @brewer.wait(@recipe['mash_time'])
    @com.ping("🍺 Mash complete 🍺. Check for starch conversion.")
    puts "Mash complete"
    puts "Check for starch conversion"
  end

  def mashout
    @com.ping("Start heating sparge water")

    @brewer.sv(@recipe['mashout_temp'])

    @brewer.pump(1)
    @brewer.pid(1)

    @com.ping("Heating to #{@brewer.sv}... this could take a few minutes.")
    @brewer.watch
    @com.ping("Mashout temperature (#{@brewer.pv}) reached. Mashout complete.")
  end

  def sparge
    print "Is the sparge water heated to the correct temperature? "
    confirm ? nil : abort

    @brewer.hlt_to('mash')
    @brewer.hlt('open')

    puts "Waiting for 10 seconds. Regulate sparge balance."
    puts "(ctrl-c to abort proccess)"
    @brewer.wait(30)

    @brewer.rims_to('boil')
    @brewer.pump(1)

    @com.ping("Please check the sparge balance and ignite boil tun burner")

    puts "Waiting until intervention to turn off pump (y): "
    confirm ? nil : abort

    @brewer.pid(0)
    @brewer.pump(0)

    @brewer.hlt('close')
  end

  def top_off
    @brewer.hlt_to('boil')

    @brewer.hlt('open')

    print "waiting for intervention to turn off hlt (y): "
    confirm ? nil : abort

    @brewer.hlt('close')

    @com.ping('Topping off completed')
  end

  def boil
    @com.ping("starting boil procedure")
    @brewer.wait(to_seconds(5))
    @com.ping("Add boil hops")
    @brewer.wait(to_seconds(40))
    @com.ping("Add flovering hops")
    @brewer.wait(to_seconds(13))
    @com.ping("Add finishing hops")
    @brewer.wait(30)
    @com.ping("All done")
  end


end
