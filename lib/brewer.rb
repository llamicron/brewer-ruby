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
    sleep(time.to_f)
    true
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
      return script('set_sv', temp.to_i)
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
    raise "Relay number needs to be an Float" unless relay.is_a? Float
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

end
