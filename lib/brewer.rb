require_relative 'helpers'
require_relative 'adaptibrew'
require_relative 'slacker'

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

  def pid(state=0)
    if state == 1
      state_string = "on"
    else
      state_string = "off"
    end
    script("set_pid_#{state_string}")
    self
  end

  def all_relays_status
    script("get_relay_status_test")
    puts @out.first.split('\n')
    @out.shift
    self
  end

  def relay_status(relay)
    script("get_relay_status", "#{relay}")
    puts @out.first
    self
  end

  # Procedures

  def boot
    # These are the states required for starting. Should be called on boot.
    pid(0).pump(0).relay(2, 1).all_relays_status.relay_status(2)

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

    wait(30)
    puts "Waiting for 30 seconds (ctrl-c to cancel)"

    print "Is the strike water circulating well? "
    confirm ? nil : abort

    self
  end

end
