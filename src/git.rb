# This script is responsible for cloning the AdaptiBrew repo.
require 'git'

if !Dir.exists?('Adaptibrew')
  puts "Cloning repo..."
  Git.clone('https://github.com/adaptiman/adaptibrew.git', 'Adaptibrew')
  puts "Repo cloned successfully"
else
  puts "Adaptibrew is already there. Cloning skipped."
end
