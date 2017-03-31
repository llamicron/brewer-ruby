# This just parses the adaptibrew/settings.py
require 'adaptibrew'

adaptibrew = Adaptibrew.new

# This might not make sense, its for tests
def get_repo_for_settings
  adaptibrew.clone
end

if !adaptibrew.present?
  get_repo_for_settings
end

$settings = {}

File.open(Dir.home + '/.brewer/adaptibrew/settings.py') do |file|
  file.each_line do |line|
    if line.match(/=/) == nil
      next
    end
    key, value = line.match(/(.+)=(.+)/).captures
    value.slice!(/#.+/)
    $settings[key.strip.chomp] = value.strip.chomp
  end
end
