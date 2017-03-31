require 'git'
require 'fileutils'
require_relative 'helpers'

include Helpers

# This is the 'manager' for the adaptibrew repo. It handles cloning and such.
class Adaptibrew

  def initialize
    @install_dir = Dir.home + "/.brewer/"
  end

  # If used in IRB, Ripl, etc. it will clone into the directory IRB was started in
  def clone
    raise "🛑  Cannot clone, no network connection" unless network?
    if !Dir.exists?(@install_dir)
      # The :path part makes zero sense
      Git.clone('https://github.com/llamicron/adaptibrew.git', 'adaptibrew', :path => Dir.home + "/.brewer/")
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
    FileUtils.rm_rf(@install_dir + 'adaptibrew/')
    self
  end

  def refresh
    raise "🛑  Cannot refresh, no network connection" unless network?
    clear
    clone
    self
  end

  def present?
    if Dir.exists?(@install_dir + 'adaptibrew/')
      return true
    end
    false
  end

end
