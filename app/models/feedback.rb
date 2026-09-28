class Feedback < ApplicationRecord
  belongs_to :booking
  belongs_to :author, class_name: "User"

  validates :rating, presence: true, inclusion: { in: 1..5 }
  validates :comment, presence: true, length: { minimum: 10 }

  after_create_commit :try_advance_booking

  private

  def try_advance_booking
    booking.with_lock do
      booking.credit! if booking.may_credit?
    end
  end
end