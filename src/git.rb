# This script is responsible for cloning the AdaptiBrew repo.
require 'git'

def clone_repo(path=nil)
  # If the repo isn't there, clone it.
  if !Dir.exists?('adaptibrew')
    puts "Cloning repo..."
    Git.clone('https://github.com/adaptiman/adaptibrew.git', 'adaptibrew', :path => path)
    puts "Repo cloned successfully"
  else
    puts "Adaptibrew is already there. Cloning skipped."
  end
end
