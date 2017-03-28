require 'git'
require 'fileutils'
require_relative 'helpers'

include Helpers

# This is the 'manager' for the adaptibrew repo. It handles cloning and such.
class Adaptibrew

  # If used in IRB, Ripl, etc. it will clone into the directory IRB was started in
  def clone(path=nil)
    raise "🛑  Cannot clone, no network connection" unless network?
    if !Dir.exists?('adaptibrew')
      Git.clone('https://github.com/adaptiman/adaptibrew.git', 'adaptibrew', :path => path)
    end
    self
  end

  # Danger zone...
  def clear
    # :nocov: since this requires network to be off
    if !network?
      print "Warning: you have no network connection. If you clear, you will not be able to clone again, and you'll be stuck without the adaptibrew source. Are you sure? "
      if !confirm
        exit
      end
    end
    # :nocov:
    FileUtils.rm_rf('adaptibrew')
    self
  end

  def refresh
    raise "🛑  Cannot refresh, no network connection" unless network?
    clear
    clone
    self
  end

end
