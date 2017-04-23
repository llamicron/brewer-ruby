require_relative "../brewer"

module Brewer
  class Procedures

    attr_accessor :com, :brewer, :recipe

    def initialize
      @brewer = Brewer.new
      @com = Slacker.new
      @recipe = Recipe.new(@brewer)
    end

    # def minified_master(recipe_vars)
    #   @recipe.get_recipe_vars(recipe_vars)
    # end

    def master
      @recipe.get_recipe_vars
      boot
      heat_strike_water
      dough_in
      mash
      mashout
      sparge
      top_off
      boil
      true
    end

    def boot
      puts Rainbow("booting...").yellow
      @brewer.relay_config({
        'pid' => 0,
        'pump' => 0,
        'rims_to' => 'mash',
        'hlt_to' => 'mash'
      })
      # puts @brewer.all_relays_status
      # puts @brewer.pid

      puts Rainbow("Boot finished!").green
      @com.ping("🍺 boot finished 🍺")
      true
    end

    # :nocov:
    def heat_strike_water
      puts Rainbow("About to heat strike water").yellow

      # Confirm strike water is in the mash tun
      print Rainbow("Is the strike water in the mash tun? ").yellow
      confirm ? nil : abort

      # confirm return manifold is in the mash tun
      print Rainbow("Is the return manifold in the mash tun? ").yellow
      confirm ? nil : abort

      print Rainbow("Is the manual mash tun valve open? ").yellow
      confirm ? nil : abort

      # confirm RIMS relay is on
      @brewer.rims_to('mash')

      # turn on pump
      @brewer.pump(1)

      print Rainbow("Is the pump running properly? ").yellow
      unless confirm
        puts "restarting pump"
        @brewer.pump(0)
        @brewer.wait(2)
        @brewer.pump(1)
      end

      # confirm that strike water is circulating well
      print Rainbow("Is the strike water circulating well? ").yellow
      # -> response
      confirm ? nil : abort


      # calculate strike temp & set PID to strike temp
      # this sets PID SV to calculated strike temp automagically
      @brewer.sv(@recipe.strike_water_temp)
      puts "SV has been set to calculated strike water temp"
      # turn on RIMS heater
      @brewer.pid(1)

      # measure current strike water temp and save
      @recipe.starting_strike_temp = @brewer.pv
      puts "current strike water temp is #{@brewer.pv}."
      puts "Heating to #{@brewer.sv}"

      @com.ping("Strike water beginning to heat. This may take a few minutes.")

      # when strike temp is reached, @com.ping slack
      @brewer.watch
      puts Rainbow("Strike water heated. Maintaining temp.").green
      true
    end
    # :nocov:

    def dough_in
      @brewer.relay_config({
        'pid' => 0,
        'pump' => 0
      })
      @brewer.wait(3)
      @com.ping("Ready to dough in")
      puts Rainbow("Ready to dough in").green

      # pour in grain

      print Rainbow("Confirm when you're done with dough-in (y): ").yellow
      confirm ? nil : abort
      true
    end

    def mash
      @brewer.sv(@recipe.mash_temp)

      puts Rainbow("Mash started. This will take a while.").green
      @com.ping("Mash started. This will take a while.")

      @brewer.relay_config({
        'rims_to' => 'mash',
        'pid'  => 1,
        'pump' => 1
      })

      @brewer.watch
      @com.ping("Starting timer for #{to_minutes(@recipe.mash_time)} minutes.")
      @brewer.wait(@recipe.mash_time)
      @com.ping("🍺 Mash complete 🍺. Check for starch conversion.")
      puts Rainbow("Mash complete").green
      puts "Check for starch conversion"
    end

    def mashout
      @com.ping("Start heating sparge water")
      puts Rainbow("start heating sparge water").yellow
      puts Rainbow("Mashout started").yellow

      @brewer.sv(@recipe.mashout_temp)

      @brewer.relay_config({
        'pid'  => 1,
        'pump' => 1
      })
      @com.ping("Heating to #{@brewer.sv}... this could take a few minutes.")
      puts Rainbow("Heating to #{@brewer.sv}... this could take a few minutes.").yellow
      @brewer.watch
      @com.ping("Mashout complete.")
      puts Rainbow("Mashout complete").yellow
    end

    def sparge
      print Rainbow("Is the sparge water heated to the correct temperature? ").yellow
      confirm ? nil : abort

      puts Rainbow("Sparging started").yellow

      @brewer.relay_config({
        'hlt_to' => 'mash',
        'hlt' => 1
      })

      print "Waiting for 10 seconds. "
      puts Rainbow("Regulate sparge balance.").yellow
      @brewer.wait(10)

      @brewer.relay_config({
        'rims_to' => 'boil',
        'pump' => 1
      })

      @com.ping("Please check the sparge balance and ignite boil tun burner")
      puts Rainbow("Ignite boil tun burner").yellow

      print Rainbow("Waiting for intervention to turn off pump (y): ").yellow
      confirm ? nil : nil

      @brewer.relay_config({
        'pid' => 0,
        'pump' => 0,
        'hlt' => 0
      })

      puts Rainbow("Sparging complete").green
      true
    end

    def top_off
      puts Rainbow("Top off started").green

      @brewer.relay_config({
        'hlt_to' => 'boil',
        'hlt' => 1
      })

      print Rainbow("waiting for intervention to turn off hlt (y): ").yellow
      confirm ? nil : abort

      @brewer.hlt(0)

      @com.ping('Topping off complete')
      puts Rainbow("Topping off complete").green
    end

    def boil
      puts Rainbow("Timers started... You'll be notified when you need to add hops.").yellow
      @com.ping("starting boil procedure")
      @brewer.wait(to_seconds(5))
      @com.ping("Add boil hops")
      @brewer.wait(to_seconds(40))
      @com.ping("Add flovering hops")
      @brewer.wait(to_seconds(13))
      @com.ping("Add finishing hops")
      @brewer.wait(30)
      @com.ping("Done.")
      puts Rainbow("Done.").green
      true
    end

  end
end
