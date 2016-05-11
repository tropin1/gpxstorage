# russian date format
Date::DATE_FORMATS[:default] = '%d.%m.%Y'
Time::DATE_FORMATS[:default] = '%d.%m.%Y %H:%M'

Rails.application.configure do
  config.max_attach_size = 50.megabytes
  config.ver = File.read(Rails.root.join('public', 'ver.txt')).gsub("\n", '')
end
