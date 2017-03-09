Gem::Specification.new do |s|
  s.name               = "brewer"
  s.version            = "0.0.1"
  s.default_executable = "brewer"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Luke Sweeney"]
  s.date = %q{2017-03-08}
  s.description = %q{A Ruby API for adaptiman/adaptibrew}
  s.email = %q{luke@thesweeneys.org}
  spec.files = FileList['lib/*.rb', 'bin/*', '[A-Z]*', 'tests/*'].to_a
  spec.bindir = 'bin'
  s.test_files = ["tests/*"]
  s.homepage = %q{http://github.com/llamicron/ruby_brewer}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.6.2}
  s.summary = %q{A shell interface for adaptibrew}
  s.license = 'MIT'

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
