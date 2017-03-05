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
task :clear_repo do
  rm_rf 'adaptibrew/'
end

task :clone_repo do
  Git.clone('https://github.com/adaptiman/adaptibrew.git', 'adaptibrew')
end

task :refresh_repo do
  Rake::Task["clear_repo"].invoke
  Rake::Task["clone_repo"].invoke
end
