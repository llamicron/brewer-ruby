require_relative 'brewer'
require_relative 'helpers'
require_relative 'communicator'

include Helpers

class Procedures

  attr_accessor :com, :brewer

  def initialize
    @brewer = Brewer.new
    @com = Communicator.new
  end

  def master
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

    # wait ~30 seconds
    print "How long do you want to wait for the water to start circulating? (30) "
    # Helpers#time exists
    input_time = gets.chomp
    if input_time == ""
      input_time = 30
    end
    puts "Waiting for #{input_time} seconds for strike water to start circulating"
    puts "(ctrl-c to exit proccess now)"
    @brewer.wait(input_time.to_f)

    # confirm that strike water is circulating well
    print "Is the strike water circulating well? "
    # -> response
    confirm ? nil : abort


    # calculate strike temp & set PID to strike temp
    # this sets PID SV to calculated strike temp automagically
    @brewer.get_strike_temp
    # turn on RIMS heater
    @brewer.pid(1)

    # measure current strike water temp and save
    @@brewer.temps['starting_strike_temp'] = @brewer.pv
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
    @com.ping("dough-in procedure started")
    puts "dough-in procedure started"
    # turn pump off
  	# turn PID off
    @brewer.pump(0)
    @com.ping("Ready to dough in")
    puts "Ready to dough in"

    print "Confirm when you're done with dough-in (y): "
    confirm ? nil : abort

    @com.ping("next step: mash")
    puts "Next step: mash"
    puts "command: brewer.mash"
    # pour in grain
    true
  end

  def mash
    print "Enter mash temperature (#{@brewer.temps['desired_mash'].to_s} F): "
    temp = gets.chomp

    if temp != ""
      @brewer.temps['desired_mash'] = temp.to_f
    end

    @brewer.sv(@brewer.temps['desired_mash'].to_f)

    print "Enter mash time in seconds (3600 seconds for 1 hour). This timer will start once mash temp has been reached: "
    mash_time_input = gets.chomp

    puts "This will take a while. You'll get a slack message next time you need to do something."
    @com.ping("Mash started. This will take a while.")

    if mash_time_input == ""
      mash_time = 3600
    else
      mash_time = mash_time_input.to_f
    end

    @brewer.rims_to('mash')

    @brewer.pump(1)
    @brewer.pid(1)

    @brewer.watch
    @com.ping("Mash temp (#{@brewer.pv} F) reached. Starting timer for #{mash_time} seconds. You'll get a slack message next time you need to do something.")
    puts "Mash temp (#{@brewer.pv} F) reached. Starting timer for #{mash_time} seconds. You'll get a slack message next time you need to do something."
    @brewer.wait(mash_time)
    @com.ping("🍺 Mash complete 🍺. Check for starch conversion. Next step: mashout")
    puts "Mash complete"
    puts "Check for starch conversion"
    puts "next step: mashout"
    puts "command: brewer.mashout"
  end

  def mashout
    puts "mashout procedure started"

    print "Enter mashout temp (172 F): "
    mashout_temp_input = gets.chomp

    @com.ping("Start heating sparge water")

    # error

    if mashout_temp_input == ""
      mashout_temp = 172.0
    else
      mashout_temp == mashout_temp_input.to_f
    end

    @brewer.sv(mashout_temp)

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

    puts "Waiting for 30 seconds. Regulate sparge balance."
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

    @com.ping("Sparge complete")
  end

  def top_off
    @brewer.hlt_to('boil')

    @brewer.hlt('open')

    print "waiting for intervention to turn off hlt (y): "
    confirm ? nil : abort

    @brewer.hlt('close')

    @com.ping('Top@com.ping off completed')
  end

  def boil
    @com.ping("starting boil procedure")
    @brewer.wait(300)
    @com.ping("Add boil hops")
    @brewer.wait(2400)
    @com.ping("Add flovering hops")
    @brewer.wait(780)
    @com.ping("Add finishing hops")
    @com.ping("All done")
  end


end
