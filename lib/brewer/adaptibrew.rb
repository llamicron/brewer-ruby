require_relative "helpers.rb"

include Helpers

module Brewer
  class Adaptibrew

    # This will clone adaptibrew into ~/.brewer/adaptibrew/
    def clone
      raise "🛑  Cannot clone, no network connection" unless network?
      if !Dir.exists?(adaptibrew_dir)
        Git.clone('https://github.com/llamicron/adaptibrew.git', 'adaptibrew', :path => brewer_dir)
      end
      self
    end

    # Danger zone...
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
     # If it's not there, it will clone.
     # If it is, it will delete and re-clone
    def refresh
      raise "🛑  Cannot refresh, no network connection" unless network?
      clear
      clone
      self
    end

    def present?
      return Dir.exists?(adaptibrew_dir) ? true : false
    end

  end
end
