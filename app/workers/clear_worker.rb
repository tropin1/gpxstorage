class ClearWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false

  def perform
    system("cd #{Rails.root.join('tmp').join('tracks').to_s} && find . -type f -name '*.tmp' -mtime +1 -delete")
  end
end