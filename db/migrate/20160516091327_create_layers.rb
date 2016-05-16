class CreateLayers < ActiveRecord::Migration[5.0]
  def change
    object_ref_create(:layers, :indexed_columns => [:name]) do |t|
      t.string  :name, :null => false, :limit => 50
      t.string  :url, :null => false, :limit => 512
      t.boolean :predefined, :null => false, :default => false
      t.timestamps
    end

    Layer.create_std_layers

    change_table :tracks do |t|
      t.references :layer, :index => true, :null => false, :default => Layer.first.id
    end

    add_foreign_key :tracks, :layers, on_delete: :restrict, on_update: :cascade
  end
end
