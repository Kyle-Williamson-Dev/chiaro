class CreateSafetyReports < ActiveRecord::Migration[8.1]
  def change
    create_table :safety_reports do |t|
      t.references :booking, null: false, foreign_key: true
      t.references :reporter, null: false, foreign_key: { to_table: :users }
      t.text :body, null: false
      t.integer :status, null: false, default: 0
      t.timestamps
    end

    add_index :safety_reports, [:booking_id, :reporter_id], unique: true
  end
end
