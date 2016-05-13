class AddNewFields < ActiveRecord::Migration[5.0]
  def change
    add_column :tracks, :len, :numeric, :null => false, :default => 0, :precision => 10, :scale => 2
    add_column :track_items, :len, :numeric, :null => false, :default => 0, :precision => 10, :scale => 2
    add_column :users, :cc, :integer, :null => false, :default => 0
    add_column :users, :following, :integer, array: true
    add_index :users, :following, using: :gin

    User.all.each {|user| user.update :cc => user.tracks.count }
    Track.all.each {|track| track.calc_distances! }
  end
end
