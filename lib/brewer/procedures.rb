require_relative "../brewer"

module Brewer
  class Procedures

    attr_accessor :com, :brewer, :recipe

    def initialize
      @brewer =Brewer::Brewer.new
      @com =Brewer::Communicator.new
      @recipe =Brewer::Recipe.new(@brewer)
    end

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
    end

    def boot
      puts Rainbow("booting...").yellow
      @brewer.pid(0)
      @brewer.pump(0)
      @brewer.rims_to('mash')
      @brewer.hlt_to('mash')
      @brewer.all_relays_status
      puts @brewer.pid

      puts Rainbow("Boot finished!").green
      @com.ping("🍺 boot finished 🍺")
      true
    end

    # :nocov:
    def heat_strike_water
      puts "heat-strike-water procedure started"

      # Confirm strike water is in the mash tun
      print Rainbow("Is the strike water in the mash tun? ").yellow
      # -> response
      confirm ? nil : abort

      # confirm return manifold is in the mash tun
      print Rainbow("Is the return manifold in the mash tun? ").yellow
      # -> response
      confirm ? nil : abort

      print Rainbow("Is the mash tun valve open? ").yellow
      confirm ? nil : abort

      # confirm RIMS relay is on
      @brewer.rims_to('mash')
      puts "RIMS-to-mash relay is now on"

      # turn on pump
      @brewer.pump(1)
      puts "Pump is now on"

      puts Rainbow("Is the pump running properly? ").yellow
      # TODO: Test this
      until confirm
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
      puts "current strike water temp is #{@brewer.pv}. Saved."
      puts "Heating to #{@brewer.sv}"

      @com.ping("Strike water beginning to heat. This may take a few minutes.")

      # when strike temp is reached, @com.ping slack
      @brewer.watch
      @com.ping("Strike water heated to #{@brewer.pv}. Maintaining temperature.")
      puts Rainbow("Strike water heated. Maintaining temp.").green
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
      puts Rainbow("Ready to dough in").green

      # pour in grain

      print Rainbow("Confirm when you're done with dough-in (y): ").yellow
      confirm ? nil : abort
      true
    end

    def mash
      @brewer.sv(@recipe.mash_temp)

      puts Rainbow("mash stated. This will take a while.").green
      @com.ping("Mash started. This will take a while.")

      @brewer.rims_to('mash')

      @brewer.pump(1)
      @brewer.pid(1)

      @brewer.watch
      @com.ping("Mash temp (#{@brewer.pv} F) reached. Starting timer for #{@recipe.mash_time} minutes.")
      @brewer.wait(@recipe.mash_time)
      @com.ping("🍺 Mash complete 🍺. Check for starch conversion.")
      puts Rainbow("Mash complete").green
      puts "Check for starch conversion"
    end

    def mashout
      @com.ping("Start heating sparge water")

      @brewer.sv(@recipe.mashout_temp)

      @brewer.pump(1)
      @brewer.pid(1)

      @com.ping("Heating to #{@brewer.sv}... this could take a few minutes.")
      @brewer.watch
      @com.ping("Mashout temperature (#{@brewer.pv}) reached. Mashout complete.")
    end

    def sparge
      print Rainbow("Is the sparge water heated to the correct temperature? ").yellow
      confirm ? nil : abort

      @brewer.hlt_to('mash')
      @brewer.hlt(1)

      print "Waiting for 10 seconds. "
      puts Rainbow("Regulate sparge balance.").yellow
      puts "(ctrl-c to abort proccess)"
      @brewer.wait(30)

      @brewer.rims_to('boil')
      @brewer.pump(1)

      @com.ping("Please check the sparge balance and ignite boil tun burner")

      puts Rainbow("Waiting until intervention to turn off pump (y): ").yellow
      confirm ? nil : abort

      @brewer.pid(0)
      @brewer.pump(0)

      @brewer.hlt(0)
    end

    def top_off
      @brewer.hlt_to('boil')

      @brewer.hlt(1)

      print Rainbow("waiting for intervention to turn off hlt (y): ").yellow
      confirm ? nil : abort

      @brewer.hlt(0)

      @com.ping('Topping off complete')
      puts Rainbow("Topping off complete").green
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
      @com.ping("Done.")
      puts Rainbow("Done.").green
    end

  end
end
