require 'rake'

Gem::Specification.new do |s|
  s.name               = "brewer"
  s.version            = "0.0.35"
  s.default_executable = "brewer"

  s.authors = ["Luke Sweeney"]
  s.date = %q{2017-03-08}
  s.description = %q{A Ruby API for adaptiman/adaptibrew}
  s.post_install_message = "🍺  have fun 🍺"
  s.email = %q{luke@thesweeneys.org}
  s.files = FileList.new(['lib/*.rb', 'bin/*', '[A-Z]*', 'spec/*.rb']).to_a
  s.executables = ['brewer']
  s.bindir = 'bin'
  s.test_files = FileList.new(["spec/*.rb"]).to_a
  s.homepage = %q{https://rubygems.org/gems/brewer}
  s.require_paths = ["lib", "lib"]
  s.rubygems_version = %q{1.6.2}
  s.summary = %q{A shell interface for adaptibrew}
  s.license = 'MIT'

  # Runtime dependencies
  s.add_runtime_dependency 'git', '~> 1.3', '>= 1.3.0'
  s.add_runtime_dependency 'ripl', '~> 0.7.0'
  s.add_runtime_dependency 'net-ping', '~> 1.7'
  s.add_runtime_dependency 'slack-notifier'

  # Dev dependencies
  s.add_development_dependency 'rake', '~> 12.0', '>= 12.0.0'
  s.add_development_dependency 'rspec', '~> 3.5.0', '>= 3.5.0'
  s.add_development_dependency 'launchy', '~> 2.4', '>= 2.4.0'
  s.add_development_dependency 'simplecov', '~> 0.13.0'
  s.add_development_dependency 'simplecov-html', '~> 0.10.0'
  s.add_development_dependency 'rdoc', '~> 5.1', '>= 5.1.0'
end
