class FeedbackPolicy < ApplicationPolicy
  def create?
    booking = record.booking
    party = user == booking.model || user == booking.photographer
    already_posted = booking.feedbacks.where(author: user).exists?

    party && booking.feedback_pending? && !already_posted
  end
end