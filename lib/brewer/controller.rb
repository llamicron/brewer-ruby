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

      @db = Brewer::DB.new
    end

    public

    # Runs an adaptibrew script (written in python)
    def script(script, params=nil)
      `python #{@base_path}/adaptibrew/#{script}.py #{params}`.chomp
    end

    # Turns the pump on and off, or returns the status if no arg
    # Turning the pump off will turn the pid off too, as it should not be on when the pump is off
    def pump(state="status")
      record = @db.get_latest_record
      if state == "status"
        # return relay_status($settings['pump'])
        return record['pump'].to_b
      end

      if state == 1
        return script("set_pump_on")
      else
        if record['pid_running'].to_b
          pid(0)
        end
        return script("set_pump_off")
      end
    end

    # Turns PID on or off, or gets status if no arg is provided
    def pid(state="status")
      record = @db.get_latest_record

      if state == "status"
        return {
          'pid_running' => record['pid_running'].to_b,
          'sv_temp' => record['sv'],
          'pv_temp' => record['pv']
        }
      end

      if state == 1
        script('set_pid_on')
        pump(1)
        return "Pump and PID are now on"
      else
        return script("set_pid_off")
      end
    end

    # This is for jake's js
    def pid_to_web
      record = @db.get_latest_record

      return {
        'pid_running' => record['pid_running'].to_b,
        'sv' => record['sv'],
        'pv' => record['pv']
      }
    end


    # Sets the setpoint value (sv) on the PID, or returns the current SV
    def sv(temp=nil)
      if temp
        return script('set_sv', temp).to_f
      end
      @db.get_latest_record['sv']
    end

    # Returns the proccess value (this one can't be changed)
    def pv
      @db.get_latest_record['pv']
    end

    # This method will wait until the pv >= sv
    # Basically when the mash tun is at the set temperate, it will ping and return self.
    # It will also display a status table every 2 seconds
    # :nocov:
    def watch
      until pv >= sv do
        wait(2)
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
        wait(1)
        clear_screen
        puts table
      end
    end
    # :nocov:

    # This returns a status table
    def status_table
      status_table_rows = [
        ["Current Temp", pv],
        ["Set Value Temp", sv],
        ["PID is: ", @db.get_latest_record['pid_running'].to_b ? "on" : "off"],
        ["Pump is: ", pump]
      ]

      status_table = Terminal::Table.new :headings => ["Item", "Status"], :rows => status_table_rows
      status_table
    end

    # Turns a relay on or off
    def relay(relay, state)
      script("set_relay", "#{relay} #{state}")
      true
    end

    # Returns the status of a single relay
    def relay_status(relay)
      record = @db.get_latest_record
      if record[record.key("relay")].to_b
        return "on"
      else
        return "off"
      end
    end

    # Returns the status of all relays
    def all_relays_status
      output = script("get_relay_status_test").split("\n")
      output.shift(3)
      return output
    end

    # This returns a prettier version of all_relays_status, and only returns the
    # relays in use, being 0-3.
    def relays_status
      statuses = {}
      all_relays_status.shift(4).each do |status|
        relay_num, status = status.match(/relay [0-9+]([0-9]+): (on|off)/).captures
        relay_names = $settings.select { |key, value| key.to_s.match(/hlt|rims[^A]|pump/) }
        statuses[relay_names.key(relay_num.to_i)] = status
      end
      statuses
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
