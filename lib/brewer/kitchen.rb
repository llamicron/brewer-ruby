require_relative "../brewer"

module Brewer
  class Kitchen

    def initialize
      @kitchen_url = "http://github.com/llamicron/kitchen.git"
    end

    def clear
      if present?
        FileUtils.rm_rf(kitchen_dir)
        return true
      end
      false
    end

    def clone
      if !present?
        Git.clone(@kitchen_url, "kitchen", :path => brewer_dir)
        return true
      end
      false
    end

    def refresh
      clear
      clone
      true
    end

    def present?
      if Dir.exists?(kitchen_dir)
        if Dir.entries(kitchen_dir).length > 2
          return true
        end
      end
      false
    end

    def list_recipes
      return Dir.entries(kitchen_dir).select {|file| file.match(/\.yml/) }
    end

    def list_recipes_as_table
      if list_recipes.empty?
        return "No Saved Recipes"
      else
        recipes_table_rows = list_recipes.each_slice(5).to_a
        recipes_table = Terminal::Table.new :title => "All Recipes", :rows => recipes_table_rows
        return recipes_table
      end
    end

  end
end
