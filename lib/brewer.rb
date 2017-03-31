require_relative 'helpers'
require_relative 'adaptibrew'
require_relative 'settings'

include Helpers

class Brewer

  attr_reader :base_path
  attr_accessor :out, :log

  def initialize
    @base_path = Dir.pwd
    # Output of adaptibrew
    @out = []
    @log = @base_path + '/logs/output'
    @strike_water_temp = {}
  end

  public

  # General methods

  def wait(time=30)
    sleep(time)
    self
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
  def script(script, params=nil)
    @out.unshift(`python #{@base_path}/adaptibrew/#{script}.py #{params}`.chomp)
    self
  end

  # Clears the @out array
  # Writes current @out to log
  def clear
    write_log(@log, @out)
    @out = []
    self
  end

  # This lil' divider is default for large return blocks
  def echo(string="----------")
    puts string
    self
  end


  # Adaptibrew methods

  def pump(state=0)
    if state == 1
      script("set_pump_on")
    else
      script("set_pump_off")
    end
    self
  end

  def relay(relay, state)
    script("set_relay", "#{relay} #{state}")
    self
  end

  # Turns PID on or off, or gets state if no arg is provided
  def pid(state="status")
    if state == "status"
      script("is_pid_running")
      puts "PID is running? " + @out.first
      sv
      pv
    end

    if state == 1
      script('set_pid_on')
      puts "PID is now on"
    elsif state == 0
      script("set_pid_off")
      puts "PID is now off"
    end

    self
  end

  def all_relays_status
    script("get_relay_status_test")
    puts @out.first.split('\n')
    @out.shift
    self
  end

  def relay_status(relay)
    raise "Relay number needs to be an integer" unless relay.is_a? Integer
    script("get_relay_status", "#{relay}")
    puts @out.first
    self
  end

  def sv(temp=nil)
    if temp
      raise "Temperature input needs to be an integer" unless temp.is_a? Integer
      script('set_sv', temp)
      puts "SV set to #{temp}"
    else
      script('get_sv')
      puts "SV is " + @out.first
    end
    self
  end

  def pv
    script('get_pv')
    puts "PV is " + @out.first
    self
  end

  # WaterVolInQuarts, GrainMassInPounds, GrainTemp, MashTemp
  def get_strike_temp
    print "Input amount of water in quarts: "
    water = gets.chomp

    print "Input amount of grain in lbs: "
    grain = gets.chomp

    pv
    print "Input current grain temp (return for default above): "
    grain_temp = gets.chomp
    if grain_temp == ""
      grain_temp = pv
      grain_temp = 60
    end

    print "Input desired mash temp (150): "
    desired_mash_temp = gets.chomp
    if desired_mash_temp == ""
      desired_mash_temp = 150
    end

    script('get_strike_temp', "#{water} #{grain} #{grain_temp} #{desired_mash_temp}")
    sv(@out.first.to_i)
    puts @out.first
  end


  # Procedures

  def boot
    # These are the states required for starting. Should be called on boot.
    # Print PID status at end
    pid(0).pump(0).relay($settings['rimsToMashRelay'], 1).all_relays_status.echo.pid.echo

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

    puts "Waiting for 30 seconds (ctrl-c to cancel)"
    wait(30)

    print "Is the strike water circulating well? "
    confirm ? nil : abort



    print "Desired mash temp: "
    sv(gets.chomp)

    @strike_water_temp[Time.now] = pv
    puts "current strike water temp is #{pv}. Saved."
    puts "Warning: if you exit this brewer shell, the strike water temp will be lost"

    # calculate strike temp

    # set PID to strike temp

    # when strike temp is reached, ping

    self
  end

end
