require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)
Dir.glob(File.expand_path('lib/**/*.rb')) {|file| require file}

module Gpxstorage
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    config.time_zone = 'Asia/Yekaterinburg'
    config.i18n.enforce_available_locales = true
    config.i18n.default_locale = :ru
    config.active_job.queue_adapter = :sidekiq

    #config.middleware.delete Rack::Lock
    config.redis_options = { url: 'unix:/var/run/redis/redis.sock', :db => 11 }
  end
end
