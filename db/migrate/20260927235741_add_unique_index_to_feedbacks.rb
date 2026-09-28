class AddUniqueIndexToFeedbacks < ActiveRecord::Migration[8.1]
  def change
    add_index :feedbacks, [:booking_id, :author_id], unique: true
  end
end
