# This just parses the adaptibrew/settings.py
require 'adaptibrew'

adaptibrew = Adaptibrew.new

if !adaptibrew.present?
  adaptibrew.clone
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
