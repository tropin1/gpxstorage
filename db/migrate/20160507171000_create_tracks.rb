class CreateTracks < ActiveRecord::Migration[5.0]
  def change
    object_ref_create(:tracks, :indexed_columns => [:name, :descr]) do |t|
      t.string      :code, :limit => 52, :null => false
      t.string      :name, :limit => 255, :null => false
      t.references  :user, :index => true
      t.text        :descr
      t.boolean     :public, :null => false, :default => true

      t.timestamps
    end

    add_index :tracks, :code, :unique => true
    add_foreign_key :tracks, :users, on_delete: :restrict, on_update: :cascade
  end
end
