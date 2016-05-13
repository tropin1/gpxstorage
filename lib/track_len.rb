module TrackLen
  def len
    (super || 0).round(2)
  end
end