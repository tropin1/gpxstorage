class ClearWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false

  def perform
    Attach
        .where(:temporary => true)
        .where("date_trunc('d', created_at) < date_trunc('d', now() at time zone 'utc') - '1 day'::interval")
          .destroy_all

    %w(tracks files).each do |folder|
      dir = Rails.root.join('tmp').join(folder).to_s
      system("cd #{dir} && find . -type f -name '*.tmp' -mtime +1 -delete") if Dir.exist?(dir)
    end
  end
end