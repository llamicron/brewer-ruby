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
      @db.execute("SELECT * FROM info WHERE timestamp + id = (SELECT MAX(timestamp + id) FROM info);").first
    end

    def get_all_records
      @db.execute("SELECT * FROM info;")
    end

  end
end
