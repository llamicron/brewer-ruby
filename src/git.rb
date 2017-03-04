# This script is responsible for cloning the adaptibrew repo.
require 'git'
require 'fileutils'

class RepoManager

  def clone(path=nil)
    if !Dir.exists?('adaptibrew')
      Git.clone('https://github.com/adaptiman/adaptibrew.git', 'adaptibrew', :path => path)
    else
      "Adaptibrew is already there. Cloning skipped."
    end
    true
  end

  # Danger zone...
  def clear(path='adaptibrew')
    raise 'Warning! This will delete a directory other than the `adaptibrew` directory' unless path.include? 'adaptibrew'
    FileUtils.rm_rf(path)
    true
  end

  # This can also serve as an update method
  def refresh
    clear
    clone
    true
  end
end
