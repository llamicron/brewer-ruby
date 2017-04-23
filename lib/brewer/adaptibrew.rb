require_relative "helpers.rb"

include Helpers

module Brewer
  # This class handles the adaptibrew repo
  # It is stored in ~/.brewer/adaptibrew/
  class Adaptibrew

    def initialize
      if !Dir.exists?(adaptibrew_dir)
        Dir.mkdir(adaptibrew_dir)
      end
    end

    # This will clone adaptibrew into ~/.brewer/adaptibrew/
    def clone
      raise "🛑  Cannot clone, no network connection" unless network?

      if !Dir.exists?(adaptibrew_dir)
        Git.clone('https://github.com/llamicron/adaptibrew.git', 'adaptibrew', :path => brewer_dir)
      end

      self
    end

    # Danger zone...
    # This deletes adaptibrew
    def clear
      # :nocov: since this requires network to be off
      if !network?
        print "Warning: you have no network connection. If you clear, you will not be able to clone again, and you'll be stuck without the adaptibrew source. Are you sure? "
        confirm ? nil : abort
      end
      # :nocov:
      FileUtils.rm_rf(adaptibrew_dir)
      self
    end

     # This is a good catch-all method
     # This deletes and re-clones adaptibrew
    def refresh
      raise "🛑  Cannot refresh, no network connection" unless network?
      clear
      clone
      self
    end

    # Returns true if adaptibrew is present
    def present?
      return Dir.exists?(adaptibrew_dir) ? true : false
    end

  end
end
