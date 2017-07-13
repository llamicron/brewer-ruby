module Brewer
  class Info

    attr_reader :data

    def initialize
      @db = DB.new
      @data = update
    end

    public

    def update
      @data = @db.get_latest_info.reject { |k, v| k.is_a? Integer }
    end

  end
end
