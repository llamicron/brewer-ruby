require 'rake'

Gem::Specification.new do |s|
  s.name               = "brewer"
  s.version            = "0.0.9"
  s.default_executable = "brewer"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Luke Sweeney"]
  s.date = %q{2017-03-08}
  s.description = %q{A Ruby API for adaptiman/adaptibrew}
  s.email = %q{luke@thesweeneys.org}
  s.files = FileList.new(['lib/*.rb', 'bin/*', '[A-Z]*', 'tests/*.rb']).to_a
  s.executables = ['brewer']
  s.bindir = 'bin'
  s.test_files = FileList.new(["tests/*.rb"]).to_a
  s.homepage = %q{http://github.com/llamicron/brewer}
  s.require_paths = ["lib", "lib"]
  s.rubygems_version = %q{1.6.2}
  s.summary = %q{A shell interface for adaptibrew}
  s.license = 'MIT'

  # TODO: update these versions

  s.add_runtime_dependency 'git', '~>1.3.0'
  s.add_runtime_dependency 'ripl', '~>?0.7.0'

  s.add_development_dependency 'rake', '~>12.0.0'
  s.add_development_dependency 'test-unit', '~>3.2.0'
  s.add_development_dependency 'launchy', '~>2.4.0'
  s.add_development_dependency 'simplecov', '~>0.13.0'
  s.add_development_dependency 'simplecov-html', '~>0.10.0'
  s.add_development_dependency 'rdoc', '~>5.1.0'
end
