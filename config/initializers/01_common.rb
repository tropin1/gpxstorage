# russian date format
Date::DATE_FORMATS[:default] = '%d.%m.%Y'
Time::DATE_FORMATS[:default] = '%d.%m.%Y %H:%M'

Rails.application.configure do
  config.max_attach_size = 2.megabytes
  config.time_zone = 'Asia/Yekaterinburg'
  config.i18n.enforce_available_locales = true
  config.i18n.default_locale = :ru
end
