require 'git'
require 'launchy'

task default: %w[test]

# Unit testing
# Travis CI uses this
task :test, [:tc] do |t, tc|
  if tc.to_a.any?
    ruby "tests/tc_#{tc.to_a[0]}.rb"
  else
    ruby "tests/ts_all.rb"
  end
end

# Opens code coverage in your browser
# This may be a bit shaky. Only tested on Mac.
# You can just open 'coverage/index.html' in your browser.
task :coverage do
  Launchy.open(Dir.pwd + '/coverage/index.html')
end

# Clears coverage report
task :clear_coverage do
  rm_rf('coverage/')
end

# Adaptibrew tasks
task :adaptibrew, [:method] do |t, method|
  case method.to_a.first
  when 'clear'
    rm_rf 'adaptibrew/'
  when 'clone'
    Git.clone('https://github.com/adaptiman/adaptibrew.git', 'adaptibrew')
  when 'refresh'
    rm_rf 'adaptibrew/'
    Git.clone('https://github.com/adaptiman/adaptibrew.git', 'adaptibrew')
  end
end
