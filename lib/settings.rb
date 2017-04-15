require_relative "autoload"

$settings = {}

adaptibrew = Adaptibrew.new
# This might not make sense, its for tests
def get_repo_for_settings(adaptibrew)
  adaptibrew.clone
end
if !adaptibrew.present?
  get_repo_for_settings(adaptibrew)
end
# End nonsense

$settings['settings_cache'] = Dir.home + "/.brewer/.settings.yml"
adaptibrew_settings_file = Dir.home + '/.brewer/adaptibrew/settings.py'

def parse_setting_from_line(line)
  key, value = line.match(/(.+)=(.+)/).captures
  value.slice!(/#.+/)
  $settings[key.strip.chomp] = value.strip.chomp
end

unless File.readlines(adaptibrew_settings_file).grep(/DEBUG/).size > 0
  File.readlines(adaptibrew_settings_file) do |line|
    if !line.include? "="
      next
    end
    parse_setting_from_line(line)
  end

  store = YAML::Store.new $settings['settings_cache']
  store.transaction {
    $settings.each do |k, v|
      store[k] = v
    end
  }
else
  File.readlines(adaptibrew_settings_file).each do |line|
    if !line.include? "="
      next
    end
    parse_setting_from_line(line)
  end
end
