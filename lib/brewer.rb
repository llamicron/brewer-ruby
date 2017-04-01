# TODO: Test monitor method
require_relative 'helpers'
require_relative 'adaptibrew'
require_relative 'settings'

include Helpers

class Brewer

  attr_reader :base_path
  attr_accessor :out, :log, :temps

  def initialize
    @base_path = Dir.home + '/.brewer'
    # Output of adaptibrew
    @out = []
    @log = @base_path + '/logs/output'
    @temps = {}
  end

  public

  # Brewer methods ------------------------------------------------------
  # general utilities for the brewer class

  def wait(time=30)
    sleep(time)
    true
  end

  # Sends a slack message in #brewing
  def ping(message="ping at #{Time.now}")
    require_relative 'slacker'
    $slack.ping(message)
  end

  # Only works on Mac :(
  # :nocov:
  def say(message="done")
    system("say #{message}")
  end
  # :nocov:

  # Runs an adaptibrew script
  # Output will be stored in @out
  # you may see `echo` quite a bit. This will almost always be directly after calling a script
  # It will be set to the output of the last script. I can't just return the output because i need to return self
  def script(script, params=nil)
    @out.unshift(`python #{@base_path}/adaptibrew/#{script}.py #{params}`.chomp)
    @out.first
  end

  # Clears the @out array
  # Writes current @out to log
  def clear
    @out = []
  end

  # This lil' divider is default for large return blocks
  def echo(string=nil)
    if string == nil
      puts @out.first
      return @out.first
    end
    puts string
    return string
  end


  # Adaptibrew methods ----------------------------------------------
  # for working with the rig

  def pump(state=0)
    if state == 1
      return script("set_pump_on")
    elsif state == 0
      if pid['pid_running'] == "True"
        pid(0)
        echo
      end
      return script("set_pump_off")
    end
  end

  # Turns PID on or off, or gets state if no arg is provided
  def pid(state="status")
    if state == "status"
      return {
        'pid_running' => script("is_pid_running"),
        'sv_temp' => sv,
        'pv_temp' => pv
      }
    end

    if state == 1
      script('set_pid_on')
      pump(1)
      return "Pump and PID are now on"
    elsif state == 0
      return script("set_pid_off")
    end
  end

  def sv(temp=nil)
    if temp
      raise "Temperature input needs to be an integer" unless temp.is_a? Integer
      return script('set_sv', temp)
    else
      return script('get_sv')
    end
  end

  def pv
    return script('get_pv')
  end

  def relay(relay, state)
    script("set_relay", "#{relay} #{state}")
    wait(10)
  end

  def all_relays_status
    script("get_relay_status_test")
    puts @out.first.split('\n')
    @out.shift
    true
  end

  # TODO: Fix the return value here
  def relay_status(relay)
    raise "Relay number needs to be an integer" unless relay.is_a? Integer
    script("get_relay_status", "#{relay}")
    return @out.first.split('\n')
  end

  # :nocov:
  def watch
    until pv.to_f >= sv.to_f do
      wait(8)
    end
    true
  end
  # :nocov:

  def monitor
    while true do
      pid.each do |k, v|
        ping("#{k}: #{v}")
      end
      wait(600)
    end
  end

  # WaterVolInQuarts, GrainMassInPounds, GrainTemp, MashTemp
  # :nocov:
  def get_strike_temp
    print "Input amount of water in quarts: "
    water = gets.chomp

    print "Input amount of grain in lbs: "
    grain = gets.chomp

    print "Input current grain temp (#{pv}): "
    grain_temp = gets.chomp
    if grain_temp == ""
      grain_temp = pv.to_i
    end

    print "Input desired mash temp (150): "
    desired_mash_temp = gets.chomp
    if desired_mash_temp == ""
      desired_mash_temp = 150
    end
    @temps['desired_mash'] = desired_mash_temp

    # this is where the magic happens
    @temps['strike_water_temp'] = script('get_strike_temp', "#{water} #{grain} #{grain_temp} #{desired_mash_temp}")
    sv(echo.to_i)
    puts "SV has been set to #{sv} degrees"
  end
  # :nocov:

  # Relays ----------
  def rims_to(location)
    if location == "mash"
      # we ended up swapping this relay, so the name is backwards
      relay($settings['rimsToMashRelay'], 0)
    elsif location == "boil"
      relay($settings['rimsToMashRelay'], 1)
    end
    true
  end

  def hlt_to(location)
    if location == "mash"
      relay($settings['spargeToMashRelay'], 0)
    elsif location == "boil"
      relay($settings['spargeToMashRelay'], 1)
    end
    true
  end

  def hlt(state)
    if state == "open"
      relay($settings['spargeRelay'], 1)
    elsif state == "close"
      relay($settings['spargeRelay'], 0)
    end
    true
  end

  # Master Procedures -----------------------------------------------------
  # The main steps in the brewing proccess
  def boot
    # These are the states required for starting. Should be called on boot.
    # Print PID status at end
    ping("booting...")
    pid(0)
    pump(0)
    rims_to('mash')
    hlt_to('mash')
    all_relays_status
    puts pid

    clear
    puts "Boot successful!"
    @out.unshift("successful boot at #{Time.now}")
    ping("🍺 boot successful 🍺")
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
    rims_to('mash')
    puts "RIMS-to-mash relay is now on"

    # turn on pump
    pump(1)
    puts "Pump is now on"

    # wait ~30 seconds
    print "How long do you want to wait for the water to start circulating? (30) "
    time = gets.chomp
    if time == ""
      time = 30
    end
    puts "Waiting for #{time} seconds for strike water to start circulating"
    puts "(ctrl-c to exit proccess now)"
    wait(time.to_i)

    # confirm that strike water is circulating well
    print "Is the strike water circulating well? "
    # -> response
    confirm ? nil : abort


    # calculate strike temp & set PID to strike temp
    # this sets PID SV to calculated strike temp automagically
    get_strike_temp
    # turn on RIMS heater
    pid(1)

    # measure current strike water temp and save
    @temps['starting_strike_temp'] = pv.to_i
    puts "current strike water temp is #{pv}. Saved."
    puts "Heating to #{sv}"

    ping("Strike water beginning to heat. This may take a few minutes.")

    # when strike temp is reached, ping slack
    watch
    ping("Strike water heated to #{pv}. Maintaining temperature.")
    ping("Next step: dough in")
    puts "Next step: dough in"
    puts "command: brewer.dough_in"

    true
  end
  # :nocov:

  def dough_in
    ping("dough-in procedure started")
    puts "dough-in procedure started"
    # turn pump off
  	# turn PID off
    pump(0)
    ping("Ready to dough in")
    puts "Ready to dough in"

    print "Confirm when you're done with dough-in (y): "
    confirm ? nil : abort

    ping("next step: mash")
    puts "Next step: mash"
    puts "command: brewer.mash"
    # pour in grain
    true
  end

  def mash
    print "Enter mash temperature (#{@temps['desired_mash'].to_s} F): "
    temp = gets.chomp

    if temp != ""
      @temps['desired_mash'] = temp.to_i
    end

    sv(@temps['desired_mash'])

    print "Enter mash time in seconds (3600 seconds for 1 hour). This timer will start once mash temp has been reached: "
    mash_time_input = gets.chomp

    puts "This will take a while. You'll get a slack message next time you need to do something."
    ping("Mash started. This will take a while. You'll get a slack message next time you need to do something.")

    if mash_time_input == ""
      mash_time = 3600
    else
      mash_time = mash_time_input.to_i
    end

    rims_to('mash')

    pump(1)
    pid(1)

    watch
    ping("Mash temp (#{pv} F) reached. Starting timer for #{mash_time} seconds. You'll get a slack message next time you need to do something.")
    puts "Mash temp (#{pv} F) reached. Starting timer for #{mash_time} seconds. You'll get a slack message next time you need to do something."
    wait(mash_time)
    ping("🍺 Mash complete 🍺. Check for starch conversion. Next step: mashout")
    puts "Mash complete"
    puts "Check for starch conversion"
    puts "next step: mashout"
    puts "command: brewer.mashout"
  end

  def mashout
    puts "mashout procedure started"

    print "Enter mashout temp (172 F): "
    mashout_temp_input = gets.chomp

    ping("Start heating sparge water")

    if mashout_temp_input == ""
      mashout_temp = 172.0
    else
      mashout_temp == mashout_temp_input.to_f
    end

    sv(mashout_temp)

    pump(1)
    pid(1)

    ping("Heating to #{sv}... this could take a few minutes.")
    watch
    ping("Mashout temperature (#{pv}) reached. Mashout complete.")
  end

  def sparge
    print "Is the sparge water heated to the correct temperature? "
    confirm ? nil : abort

    hlt_to('mash')
    hlt('open')

    puts "Waiting for 30 seconds. Regulate sparge balance."
    puts "(ctrl-c to abort proccess)"
    wait(30)

    rims_to('boil')
    pump(1)

    ping("Please check the sparge balance and ignite boil tun burner")

    puts "Waiting until intervention to turn off pump (y): "
    confirm ? nil : abort

    pid(0)
    pump(0)

    hlt('close')

    ping("Sparge complete")
  end

  def top_off
    hlt_to('boil')

    hlt('open')

    print "waiting for intervention to turn off hlt (y): "
    confirm ? nil : abort

    hlt('close')

    ping('Topping off completed')
  end

end
