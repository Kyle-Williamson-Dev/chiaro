class CreateProfiles < ActiveRecord::Migration[8.1]
  def change
    create_table :profiles do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }
      t.string :display_name, null: false
      t.text :bio
      t.string :city
      t.string :instagram
      t.text :boundaries
      t.string :shoot_types, array: true, default: []
      t.timestamps
    end
  end
end
