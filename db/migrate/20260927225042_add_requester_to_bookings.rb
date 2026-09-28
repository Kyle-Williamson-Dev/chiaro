class AddRequesterToBookings < ActiveRecord::Migration[8.1]
  def change
    add_reference :bookings, :requester, foreign_key: { to_table: :users }
  end
end
