require 'rake'

Gem::Specification.new do |s|
  s.name               = "brewer"
  s.version            = "1.0.1"
  s.default_executable = "brewer"

  s.authors = ["Luke Sweeney"]
  s.date = %q{2017-03-08}
  s.description = %q{A Ruby API for adaptiman/adaptibrew}
  s.post_install_message = "🍺  have fun 🍺"
  s.email = %q{luke@thesweeneys.org}
  s.files = FileList.new(['lib/*.rb', 'lib/brewer/*.rb', 'bin/*', 'views/*', '[A-Z]*', 'spec/*.rb']).to_a
  s.executables = ['brewer']
  s.bindir = 'bin'
  s.test_files = FileList.new(["spec/*.rb"]).to_a
  s.homepage = %q{https://rubygems.org/gems/brewer}
  s.require_paths = ["lib", "lib"]
  s.rubygems_version = %q{1.6.2}
  s.summary = %q{A shell interface for adaptibrew}
  s.license = 'MIT'

  # Runtime dependencies
  s.add_runtime_dependency 'brewer-adaptibrew'
  s.add_runtime_dependency 'git'
  s.add_runtime_dependency 'net-ping'
  s.add_runtime_dependency 'wannabe_bool'
  s.add_runtime_dependency 'slack-notifier'
  s.add_runtime_dependency 'require_all'
  s.add_runtime_dependency 'terminal-table'
  s.add_runtime_dependency 'rainbow'
  s.add_runtime_dependency 'pry'


  # Dev dependencies
  s.add_development_dependency 'rake', '~> 12.0', '>= 12.0.0'
  s.add_development_dependency 'rspec', '~> 3.5.0', '>= 3.5.0'
  s.add_development_dependency 'simplecov', '~> 0.13.0'
  s.add_development_dependency 'simplecov-html', '~> 0.10.0'
  s.add_development_dependency 'rdoc', '~> 5.1', '>= 5.1.0'
end
