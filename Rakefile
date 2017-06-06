require 'git'
require 'rdoc/task'
require 'rspec/core/rake_task'

task default: %w[spec]

RSpec::Core::RakeTask.new do |t|
  t.pattern = "spec/*_spec.rb"
  t.verbose = false
end

# Generate or update documentation
# Generates in `doc/`
RDoc::Task.new do |rdoc|
  # rm_rf "doc/"
  rdoc.rdoc_dir = 'doc/'
  rdoc.main = "README.md"
  # rdoc.rdoc_files.include("**/*.rb")
end

# Opens documentation.
task :docs do
  Launchy.open(Dir.pwd + '/doc/index.html')
end

# Clears coverage report
task :clear_coverage do
  rm_rf('coverage/')
end

task :console do
  require 'pry'
  require_relative 'lib/brewer'

  Brewer::load_settings

  def reload!
    files = $LOADED_FEATURES.select { |feat| feat =~ /\/brewer\// }
    files.each { |file| load file }
  end

  ARGV.clear
  Pry.start
end
