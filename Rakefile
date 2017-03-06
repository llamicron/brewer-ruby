require 'git'

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

# Clears code coverage reports
task :clear_coverage do
  rm_rf 'coverage/'
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
