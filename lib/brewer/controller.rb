require_relative "../brewer"

module Brewer
  # This class handles the physical brewing rig.
  # Turning on valves, the pump, RIMS and such
  class Controller

    attr_reader :base_path, :db
    attr_accessor :temps, :relays

    def initialize
      @base_path = Dir.home + '/.brewer'
      Brewer::load_settings
      @temps = {}
      @db = DB.new

      @info = Info.new
    end

    public

    # Turns the pump on and off, or returns the status if no arg
    # Turning the pump off will turn the pid off too, as it should not be on when the pump is off
    def pump(state = "status")
      @info.update
      if state == "status"
        # return relay_status($settings['pump'])
        if @info.data['pump'] == 0
          return "off"
        else
          return "on"
        end
      end

      if state == 1
        relay($settings['pump'], 1)
        return "pump on"
      else
        if info.data['pid_running'].to_b
          pid(0)
        end
        relay($settings['pump'], 0)
        return "pump off"
      end
    end

    # Turns PID on or off, or gets status if no arg is provided
    def pid(state="status")
      info.update
      if state == "status"
        return {
          'pid_running' => @info.data['pid_running'].to_b,
          'sv_temp' => @info.data['sv'],
          'pv_temp' => @info.data['pv']
        }
      end

      if state == 1
        @db.write_request('set_pid_on')
        pump(1)
        return "Pump and PID are now on"
      else
        @db.write_request('set_pid_off')
        return "PID off"
      end
    end

    # This is for jake's js
    def pid_to_web
      status = pid
      status["sv"] = status.delete "sv_temp"
      status["pv"] = status.delete "pv_temp"
      return status
    end

    # Sets the setpoint value (sv) on the PID, or returns the current SV
    def sv(temp=nil)
      if temp
        @db.write_request('set_sv', temp.to_s)
        return temp.to_f
      end
      @info.update
      @info.data['sv'].to_f
    end

    # Returns the proccess value (this one can't be changed)
    def pv
      @info.update
      @info.data['pv'].to_f
    end

    # This method will wait until the pv >= sv
    # Basically when the mash tun is at the set temperate, it will ping and return self.
    # It will also display a status table every 2 seconds
    # :nocov:
    def watch
      until pv >= sv do
        sleep(2)
      end
      Slacker.new.ping("Temperature is now at #{pv.to_f} F")
      self
    end
    # :nocov:

    # This will display an updated status table every second
    # :nocov:
    def monitor
      while true do
        # Making a new table with TerminalTable takes about 1 second. I assign
        # it here so it has time to start up, and there's minimal lag between clearing
        # and displaying the table
        table = status_table
        sleep(1)
        clear_screen
        puts table
      end
    end
    # :nocov:

    # This returns a status table
    def status_table
      @info.update
      status_table_rows = [
        ["Current Temp", pv],
        ["Set Value Temp", sv],
        ["PID is: ", @info.data['pid_running'].to_b ? "on" : "off"],
        ["Pump is: ", pump]
      ]

      status_table = Terminal::Table.new :headings => ["Item", "Status"], :rows => status_table_rows
      status_table
    end

    # Turns a relay on or off
    def relay(relay, state)
      @db.write_request("set_relay", "#{relay} #{state}")
      sleep(2)
      true
    end

    # Returns the status of a single relay
    def relay_status(relay)
      @info.update
      if @info.data[$settings.key(relay)].to_b
        return "on"
      else
        return "off"
      end
    end

    # Returns readable status of relevant relays
    def relays_status
      @info.update
      relays = @info.data.select {|k, v| k.to_s.match(/h|ri|pu/) }
      relays.each do |k, v|
        if v == 1
          relays[k] = "on"
        else
          relays[k] = "off"
        end
      end
      relays
    end

    def relays_status_to_web
      statuses = relays_status
      statuses.each do |k, v|
        if v == "on"
          statuses[k] = 1
        else
          statuses[k] = 0
        end
      end
    end

    # Give this a relay configuration hash and it will set the relays to that configuration
    # eg. {'hlt' => 0, 'rims_to' => 'boil', 'pump' => 1}
    # This is so that we can set multiple valves at effectively the same time
    def relay_config(params)
      raise "Params must be a hash" unless params.is_a? Hash
      params.each do |method, setting|
        if method == "pump"
          setting = setting.to_i
        end
        send(method, setting)
      end
    end

    # Diverts rims valve to mash or boil tun
    def rims_to(location)
      if location == "mash"
        # we ended up swapping this relay, so the name is backwards
        relay($settings['rimsToMash'], 0)
      elsif location == "boil"
        relay($settings['rimsToMash'], 1)
      else
        raise "Not a valid location for rims valve"
      end
      self
    end

    # Diverts hlt valve to mash or boil tun
    def hlt_to(location)
      if location == "mash"
        relay($settings['hltToMash'], 0)
      elsif location == "boil"
        relay($settings['hltToMash'], 1)
      else
        raise "Not a valid location for the hlt valve"
      end
      self
    end

    # Opens or closes hlt valve
    def hlt(state)
      relay($settings['hlt'], state)
      self
    end

  end
end
