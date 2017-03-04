task default: %w[test]

task :test, [:tc] do |t, tc|
  if tc.to_a.any?
    ruby "tests/tc_#{tc.to_a[0]}.rb"
  else
    ruby "tests/ts_all.rb"
  end
end

task :clear_coverage do
  rm_rf 'coverage/'
end
