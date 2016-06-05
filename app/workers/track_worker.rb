class TrackWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false

  def perform(code)
    Track.find_by_code(code)&.calc_data!
  end
end
