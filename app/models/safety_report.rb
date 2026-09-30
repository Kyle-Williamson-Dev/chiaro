class SafetyReport < ApplicationRecord
  belongs_to :booking
  belongs_to :reporter, class_name: "User"

  enum :status, { pending_review: 0, reviewed: 1 }

  validates :body, presence: true, length: { minimum: 10 }
  validate :reporter_is_party

  private

  def reporter_is_party
    return unless booking && reporter

    unless [booking.model_id, booking.photographer_id].include?(reporter_id)
      errors.add(:reporter, "must be part of this booking")
    end
  end
end
