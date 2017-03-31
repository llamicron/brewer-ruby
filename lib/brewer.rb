require_relative 'helpers'
require_relative 'adaptibrew'

include Helpers

class Brewer

  attr_reader :base_path
  attr_accessor :out, :log

  def initialize
    @base_path = Dir.pwd
    # Output of adaptibrew
    @out = []
    @log = @base_path + '/logs/output'
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

  def echo(string="----------")
    puts string
    self
  end


  # Adaptibrew methods

  def pump(state=0)
    if state == 1
      state_string = "on"
    else
      state_string = "off"
    end
    script("set_pump_#{state_string}")
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


  # Procedures

  def boot
    # These are the states required for starting. Should be called on boot.
    # Print PID status at end
    pid(0).pump(0).relay(2, 1).all_relays_status.pid.sv.pv

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

    relay(2, 1)
    puts "RIMS relay is now on"

    pump(1)
    puts "Pump is now on"

    puts "Waiting for 30 seconds (ctrl-c to cancel)"
    wait(30)

    print "Is the strike water circulating well? "
    confirm ? nil : abort

    self
  end

end
