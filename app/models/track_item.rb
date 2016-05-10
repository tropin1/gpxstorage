class TrackItem < ApplicationRecord
  belongs_to :track, primary_key: :code, foreign_key: :track_code
  validates :name, :presence => true, :length => { :maximum => 255 }
  validates :color, :presence => true, :length => { :maximum => 20 }
end
