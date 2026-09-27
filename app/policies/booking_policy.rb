class BookingPolicy < ApplicationPolicy
  def create?
    !user.has_pending_feedback?
  end

  def show?
    user == record.model || user == record.photographer
  end

  def index?
    true
  end
end