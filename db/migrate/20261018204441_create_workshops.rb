class CreateWorkshops < ActiveRecord::Migration[8.1]
  def change
    create_table :workshops do |t|
      t.references :host, null: false, foreign_key: { to_table: :users }
      t.string :title
      t.text :description, null: false
      t.string :shoot_type, null: false
      t.datetime :starts_at, null: false
      t.integer :capacity, null: false
      t.decimal :price, precision: 8, scale: 2, null: false, default: 0
      t.string :location_area, null: false
      t.string :address, null: false
      t.text :boundaries
      t.timestamps
    end
  end
end
