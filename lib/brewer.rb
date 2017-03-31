require_relative 'helpers'
require_relative 'adaptibrew'
require_relative 'settings'

include Helpers

class Brewer

  attr_reader :base_path
  attr_accessor :out, :log, :temps

  def initialize
    @base_path = Dir.pwd
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
  def say(message="done")
    system("say #{message}")
  end

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
    end
    puts string
  end


  # Adaptibrew methods ----------------------------------------------
  # for working with the rig

  def pump(state=0)
    if state == 1
      script("set_pump_on")
      echo
      return true
    else
      if pid['pid_running'] == "True"
        pid(0)
        echo
      end
      script("set_pump_off")
      echo
      return true
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
      puts "Pump and PID are now on"
      return true
    elsif state == 0
      script("set_pid_off")
      puts "PID is now off"
      return true
    end

    true
  end

  def sv(temp=nil)
    if temp
      raise "Temperature input needs to be an integer" unless temp.is_a? Integer
      return script('set_sv', temp)
    else
      return script('get_sv')
    end
    true
  end

  def pv
    script('get_pv')
  end

  def relay(relay, state)
    script("set_relay", "#{relay} #{state}")
  end

  def all_relays_status
    script("get_relay_status_test")
    puts @out.first.split('\n')
    @out.shift
    true
  end

  def relay_status(relay)
    raise "Relay number needs to be an integer" unless relay.is_a? Integer
    script("get_relay_status", "#{relay}")
    return @out.first.split('\n')
  end

  def watch
    until pv.to_i == sv.to_i do
      wait(8)
    end
    true
  end

  # WaterVolInQuarts, GrainMassInPounds, GrainTemp, MashTemp
  def get_strike_temp
    print "Input amount of water in quarts: "
    water = gets.chomp

    print "Input amount of grain in lbs: "
    grain = gets.chomp

    print "Input current grain temp (#{pv.echo}): "
    grain_temp = gets.chomp
    if grain_temp == ""
      grain_temp = pv.echo.to_i
    end

    print "Input desired mash temp (150): "
    desired_mash_temp = gets.chomp
    if desired_mash_temp == ""
      desired_mash_temp = 150
    end
    @temps['desired_mash'] = desired_mash_temp

    # this is where the magic happens
    script('get_strike_temp', "#{water} #{grain} #{grain_temp} #{desired_mash_temp}")
    @temps['strike_water_temp'] = @out.first.to_i
    sv(echo.to_i)
    puts "SV has been set to #{sv.echo} degrees"
  end

  # Master Procedures -----------------------------------------------------
  # The main steps in the brewing proccess
  def boot
    # These are the states required for starting. Should be called on boot.
    # Print PID status at end
    pid(0).pump(0).relay($settings['rimsToMashRelay'], 1).all_relays_status.pid

    @out.shift(4)
    @out.unshift("Boot successful")
    puts @out[0] + "!"
    self
  end

  def heat_strike_water
    print "Is the strike water in the mash tun? "
    confirm ? nil : abort

    print "Is the return manifold in the mash tun? "
    confirm ? nil : abort

    relay($settings['rimsToMashRelay'], 1)
    puts "RIMS-to-mash relay is now on"

    pump(1)
    puts "Pump is now on"

    time = 30
    puts "Waiting for #{time} seconds for strike water to start circulating"
    puts "(ctrl-c to stop now)"
    wait(time)

    print "Is the strike water circulating well? "
    confirm ? nil : abort

    @temps['starting_strike_temp'] = pv.out.first.to_i
    pv
    puts "current strike water temp is #{echo}. Saved."
    puts "Warning: if you exit this brewer shell, the strike water temp will be lost"
    puts ""
    puts "--- Calculate strike temp ---"
    # this sets PID to strike temp
    get_strike_temp
    # turn on pid heater
    # XXX: This?
    pid(1)

    # when strike temp is reached, ping
    watch
    ping("strike water is now at #{pv.echo} degrees")

    self
  end

end
