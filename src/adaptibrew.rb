require 'git'
require 'fileutils'

# This is the 'manager' for the adaptibrew repo. It handles cloning and such.
class Adaptibrew

  def clone(path=nil)
    if !Dir.exists?('adaptibrew')
      Git.clone('https://github.com/adaptiman/adaptibrew.git', 'adaptibrew', :path => path)
    end
    self
  end

  # Danger zone...
  def clear(dir='adaptibrew')
    raise 'Warning! This will delete a directory other than the `adaptibrew` directory' unless dir.include? 'adaptibrew'
    FileUtils.rm_rf(dir)
    self
  end

  # This can also serve as an update method
  def refresh
    clear
    clone
    self
  end
end
