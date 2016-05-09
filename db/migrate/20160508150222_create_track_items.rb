class CreateTrackItems < ActiveRecord::Migration[5.0]
  def change
    create_table :track_items do |t|
      t.xml        :data, :null => false
      t.string     :color, :null => false, :limit => 20
      t.string     :name, :null => false, :limit => 255
      t.references :track, :index => true

      t.timestamps
    end

    add_foreign_key :track_items, :tracks, on_delete: :cascade, on_update: :cascade
  end
end
