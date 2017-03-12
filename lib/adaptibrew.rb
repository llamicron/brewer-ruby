require 'git'
require 'fileutils'

# This is the 'manager' for the adaptibrew repo. It handles cloning and such.
class Adaptibrew

  # If used in IRB, Ripl, etc. it will clone into the directory IRB was started in
  def clone(path=nil)
    if !Dir.exists?('adaptibrew')
      Git.clone('https://github.com/adaptiman/adaptibrew.git', 'adaptibrew', :path => path)
    end
    self
  end

  # Danger zone...
  def clear()
    FileUtils.rm_rf('adaptibrew')
    self
  end

  def refresh
    clear
    clone
    self
  end

end
