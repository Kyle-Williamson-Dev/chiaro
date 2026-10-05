class AddCancellationToBooking < ActiveRecord::Migration[8.1]
  def change
    add_reference :bookings, :cancelled_by, null: true, foreign_key: { to_table: :users }
    add_column :bookings, :cancel_reason, :integer
    add_column :bookings, :cancelled_at, :datetime
  end
end
