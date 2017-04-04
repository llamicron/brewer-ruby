require_relative 'helpers'
require_relative 'adaptibrew'
require_relative 'settings'

include Helpers

class Brewer

  attr_reader :base_path
  attr_accessor :out, :temps

  def initialize
    @base_path = Dir.home + '/.brewer'
    # Output of adaptibrew
    @out = []
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

  def clear
    @out = []
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
      return script('set_sv', temp).to_f
    end
    return script('get_sv').to_f
  end

  def pv
    return script('get_pv').to_f
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
    raise "Relay number needs to be an Integer" unless relay.is_a? integer
    script("get_relay_status", "#{relay}")
    return @out.first.split('\n')
  end

  # :nocov:
  def watch
    until pv >= sv do
      wait(2)
    end
    self
  end
  # :nocov:

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
