require_relative "../brewer"
# :nocov:
module Brewer
  class Procedures

    attr_accessor :com, :brewer, :recipe

    def initialize
      @controller = Controller.new
      @com = Slacker.new
      @kitchen = Kitchen.new
    end

    def master
      puts "Enter a recipe name or nothing to make a new one."
      @kitchen.list_recipes_as_table
      print ">> "
      choice = gets.chomp.strip
      if choice.empty?
        @kitchen.new_recipe
      else
        @kitchen.load(choice)
      end
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
      puts Rainbow("Booting...").yellow
      @controller.relay_config({
        'pid' => 0,
        'pump' => 0,
        'rims_to' => 'mash',
        'hlt_to' => 'mash'
      })

      puts Rainbow("Boot finished!").green
      @com.ping("🍺 boot finished 🍺")
      true
    end

    def heat_strike_water
      puts Rainbow("About to heat strike water").green

      # Confirm strike water is in the mash tun
      print Rainbow("Is the strike water in the mash tun? ").yellow
      confirm ? nil : abort

      # confirm return manifold is in the mash tun
      print Rainbow("Is the return manifold in the mash tun? ").yellow
      confirm ? nil : abort

      print Rainbow("Is the manual mash tun valve open? ").yellow
      confirm ? nil : abort

      # confirm RIMS relay is on
      @controller.rims_to('mash')

      # turn on pump
      @controller.pump(1)

      print Rainbow("Is the pump running properly? ").yellow
      unless confirm
        puts "restarting pump"
        @controller.pump(0)
        sleep(2)
        @controller.pump(1)
      end

      # confirm that strike water is circulating well
      print Rainbow("Is the strike water circulating well? ").yellow
      # -> response
      confirm ? nil : abort


      # calculate strike temp & set PID to strike temp
      # this sets PID SV to calculated strike temp automagically
      @controller.sv(@kitchen.recipe.vars['strike_water_temp'])
      puts "SV has been set to calculated strike water temp"
      # turn on RIMS heater
      @controller.pid(1)

      # measure current strike water temp and save
      @kitchen.recipe.vars['starting_strike_temp'] = @controller.pv
      puts "current strike water temp is #{@controller.pv}."
      puts "Heating to #{@controller.sv}"

      @com.ping("Strike water beginning to heat. This may take a few minutes.")

      # when strike temp is reached, @com.ping slack
      @controller.watch
      puts Rainbow("Strike water heated. Maintaining temp.").green
      true
    end

    def dough_in
      @controller.relay_config({
        'pid' => 0,
        'pump' => 0
      })
      sleep(3)
      @com.ping("Ready to dough in")
      puts Rainbow("Ready to dough in").green

      # pour in grain

      print Rainbow("Confirm when you're done with dough-in (y): ").yellow
      confirm ? nil : abort
      true
    end

    def mash
      @controller.sv(@kitchen.recipe.vars['mash_temp'])

      puts Rainbow("Mash started. This will take a while.").green
      @com.ping("Mash started. This will take a while.")

      @controller.relay_config({
        'rims_to' => 'mash',
        'pid'  => 1,
        'pump' => 1
      })

      @controller.watch
      @com.ping("Starting timer for #{to_minutes(@kitchen.recipe.vars['mash_time'])} minutes.")
      sleep(@kitchen.recipe.vars['mash_time'])
      @com.ping("🍺 Mash complete 🍺. Check for starch conversion.")
      puts Rainbow("Mash complete").green
      puts "Check for starch conversion"
    end

    def mashout
      @com.ping("Start heating sparge water")
      puts Rainbow("start heating sparge water").yellow
      puts Rainbow("Mashout started").green

      @controller.sv(@kitchen.recipe.vars['mashout_temp'])

      @controller.relay_config({
        'pid'  => 1,
        'pump' => 1
      })
      @com.ping("Heating to #{@controller.sv}... this could take a few minutes.")
      puts Rainbow("Heating to #{@controller.sv}... this could take a few minutes.").yellow
      @controller.watch
      @com.ping("Mashout complete.")
      puts Rainbow("Mashout complete").green
    end

    def sparge
      print Rainbow("Is the sparge water heated to the correct temperature? ").yellow
      confirm ? nil : abort

      puts Rainbow("Sparging started").green

      @controller.relay_config({
        'hlt_to' => 'mash',
        'hlt' => 1
      })

      print "Waiting for 10 seconds. "
      puts Rainbow("Regulate sparge balance.").yellow
      sleep(10)

      @controller.relay_config({
        'rims_to' => 'boil',
        'pump' => 1
      })

      @com.ping("Please check the sparge balance and ignite boil tun burner")
      puts Rainbow("Ignite boil tun burner").yellow

      print Rainbow("Waiting for intervention to turn off pump (y): ").yellow
      confirm ? nil : nil

      @controller.relay_config({
        'pid' => 0,
        'pump' => 0,
        'hlt' => 0
      })

      puts Rainbow("Sparging complete").green
      true
    end

    def top_off
      puts Rainbow("Top off started").green

      @controller.relay_config({
        'hlt_to' => 'boil',
        'hlt' => 1
      })

      print Rainbow("waiting for intervention to turn off hlt (y): ").yellow
      confirm ? nil : abort

      @controller.hlt(0)

      @com.ping('Topping off complete')
      puts Rainbow("Topping off complete").green
    end

    def boil
      puts Rainbow("Timers started for 1 hour... You'll be notified when you need to add hops.").yellow
      @com.ping("starting boil procedure")
      sleep(to_seconds(5))
      @com.ping("Add boil hops")
      sleep(to_seconds(40))
      @com.ping("Add flovering hops")
      sleep(to_seconds(13))
      @com.ping("Add finishing hops")
      sleep(30)
      @com.ping("Done.")
      puts Rainbow("Done.").green
      true
    end

  end
end
# :nocov:
