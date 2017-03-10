require 'git'
require 'fileutils'

# This is the 'manager' for the adaptibrew repo. It handles cloning and such.
class Adaptibrew

  # Clone the repo into the current directory, unless a path is provided
  # If used in IRB, Ripl, etc. it will clone into the directory IRB was started in
  def clone(path=nil)
    # Don't clone if it's already there.
    if !Dir.exists?('adaptibrew')
      Git.clone('https://github.com/adaptiman/adaptibrew.git', 'adaptibrew', :path => path)
    end
    self
  end

  # Danger zone...
  # Clears the adaptibrew repo
  def clear()
    FileUtils.rm_rf('adaptibrew')
    self
  end

  # Clear and re-clone the adaptibrew repo
  # This can also serve as an update method
  def refresh
    clear
    clone
    self
  end

end
