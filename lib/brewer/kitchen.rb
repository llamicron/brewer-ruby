require_relative "../brewer"

module Brewer
  class Kitchen

    attr_accessor :url, :recipe

    def initialize(url: false, recipe: false)
      if url
        @url = url
      else
        @url = "http://github.com/llamicron/kitchen.git"
      end

      @recipe = recipe if recipe
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
        Git.clone(@url, "kitchen", :path => brewer_dir)
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
      list = Dir.entries(kitchen_dir).select {|file| file.match(/\.yml/) }
      list.each {|recipe_name| recipe_name.slice!(".yml") }
      return list
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

    def recipe_exists?(recipe)
      raise "Recipe name must be a string" unless recipe.is_a? String
      if list_recipes.include?(recipe)
        return true
      end
      false
    end

    def load(recipe)
      raise "Recipe name must be a string" unless recipe.is_a? String
      raise "Recipe does not exist" unless recipe_exists?(recipe)
      @recipe = Recipe.new
      @recipe.vars = YAML.load(File.open(kitchen_dir(recipe) + ".yml"))
      true
    end

  end
end
