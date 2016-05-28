class CreateAttaches < ActiveRecord::Migration[5.0]
  def change
    create_table :attaches do |t|
      t.text        :filename, :null => false
      t.text        :filename_storage, :null => false
      t.references  :attachable, polymorphic: true, index: true, null: true
      t.string      :code, :null => false, :limit => 52
      t.boolean     :img, :null => false, :default => false
      t.boolean     :temporary, :null => false, :default => true
      t.boolean     :img, :null => false, :default => false
      t.references  :user, :index => true, :null => false

      t.timestamps
    end

    add_foreign_key :attaches, :users, on_delete: :restrict, on_update: :cascade
    add_index       :attaches, :code, unique: true
  end
end
