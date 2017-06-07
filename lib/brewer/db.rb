require "sqlite3"

module Brewer
  class DB

    def initialize
      @db_dir = Dir.home + "/.brewer/db/"
      @db_file = "exchange.db"

      @db = SQLite3::Database.new(@db_dir + @db_file)
      @db.results_as_hash = true
    end

    def get_latest_record
      sql = "SELECT * FROM info WHERE timestamp + id = (SELECT MAX(timestamp + id) FROM info);"
      begin
        @db.execute(sql).first
      rescue SQLite3::BusyException
        sleep(0.1)
        @db.execute(sql).first
      end
    end

    def get_all_records
      sql = "SELECT * FROM info;"
      begin
        @db.execute(sql)
      rescue SQLite3::BusyException
        sleep(0.1)
        @db.execute(sql)
      end
    end

    def write_request(request, args="")
      @db.execute("INSERT INTO request(method, args, timestamp) VALUES(?, ?, ?)", [request, args, Time.now.to_f])
    end

  end
end
