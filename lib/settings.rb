# This just parses the adaptibrew/settings.py
$settings = {}

File.open('adaptibrew/settings.py') do |file|
  file.each_line do |line|
    if line.match(/=/) == nil
      next
    end
    key, value = line.match(/(.+)=(.+)/).captures
    value.slice!(/#.+/)
    $settings[key.strip.chomp] = value.strip.chomp
  end
end
