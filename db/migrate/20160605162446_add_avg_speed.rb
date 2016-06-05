class AddAvgSpeed < ActiveRecord::Migration[5.0]
  def change
    change_table :track_items do |t|
      t.numeric :avg_speed, :null => false, :default => 0
    end

    change_table :tracks do |t|
      t.numeric :avg_speed, :null => false, :default => 0
    end
  end
end
