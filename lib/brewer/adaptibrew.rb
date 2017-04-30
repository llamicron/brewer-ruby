require_relative "helpers.rb"

include Helpers

module Brewer
  class Adaptibrew

    attr_accessor :disable_network_operations

    def initialize
      @disable_network_operations = network? ? false : true
      @adaptibrew_url = 'https://github.com/llamicron/adaptibrew.git'

      unless Dir.exists?(brewer_dir)
        Dir.mkdir(brewer_dir)
      end

      unless Dir.exists?(adaptibrew_dir)
        Dir.mkdir(adaptibrew_dir)
      end

    end

    def clone
      if @disable_network_operations
        return false
      end

      if !Dir.exists?(adaptibrew_dir)
        Git.clone(@adaptibrew_url, 'adaptibrew', :path => brewer_dir)
        return true
      end
      false
    end

    def clear
      if @disable_network_operations
        return false
      end

      if present?
        FileUtils.rm_rf(adaptibrew_dir)
        return true
      end
      false
    end

    def refresh
      if clear and clone
        return true
      end
      false
    end

    def present?
      return Dir.exists?(adaptibrew_dir) ? true : false
    end

  end
end
