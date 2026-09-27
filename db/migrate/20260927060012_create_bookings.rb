class CreateBookings < ActiveRecord::Migration[8.1]
  def change
    create_table :bookings do |t|
      t.references :model, null: false, foreign_key: true
      t.references :photographer, null: false, foreign_key: true
      t.integer :status
      t.datetime :completed_at

      t.timestamps

      add_column :bookings, :status, :integer, default: 0, null: false unless column_exists?(:bookings, :status)
    end
  end
end
bin/rails generate model Feedback booking:references author:references rating:integer comment:text credited_name:string