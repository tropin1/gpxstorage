Sidekiq.configure_server do |config|
  config.redis = Rails.application.config.redis_options

  #schedule_file = Rails.application.config.root.join('config', 'schedule.yml')
  #Sidekiq::Cron::Job.load_from_hash YAML.load_file(schedule_file) if File.exists?(schedule_file)
end

Sidekiq.configure_client do |config|
  config.redis = Rails.application.config.redis_options
end