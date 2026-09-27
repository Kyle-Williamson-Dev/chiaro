class CreateBookings < ActiveRecord::Migration[8.1]
  def change
    create_table :bookings do |t|
      t.references :model, null: false, foreign_key: { to_table: :users }
      t.references :photographer, null: false, foreign_key: { to_table: :users }
      t.integer :status, default: 0, null: false
      t.datetime :completed_at

      t.timestamps
    end
  end
end