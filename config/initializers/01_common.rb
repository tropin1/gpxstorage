# russian date format
Date::DATE_FORMATS[:default] = '%d.%m.%Y'
Time::DATE_FORMATS[:default] = '%d.%m.%Y %H:%M'

Rails.application.configure do
  config.max_attach_size = 50.megabytes
  config.ver = File.read(Rails.root.join('public', 'ver.txt')).gsub("\n", '')

  # google smtp
  config.action_mailer.smtp_settings = {
      :address => 'smtp.gmail.com',
      :port => 587,
      :domain => Rails.application.secrets.email_domain,
      :user_name => Rails.application.secrets.email_login,
      :password => Rails.application.secrets.email_pass,
      :authentication => :plain,
      :openssl_verify_mode => 'none',
      :enable_starttls_auto => true
  }

=begin
  # yandex smtp
  config.action_mailer.smtp_settings = {
    :address => 'smtp.yandex.ru',
    :port => 465,
    :domain => Rails.application.secrets.email_domain,
    :user_name => Rails.application.secrets.email_login,
    :password => Rails.application.secrets.email_pass,
    :authentication => :plain,
    :enable_starttls_auto => true,
    :tls => true
  }
=end

end
