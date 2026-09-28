class BookingPolicy < ApplicationPolicy
  def create?
    !user.has_pending_feedback?
  end

  def show?
    party?
  end

  def index?
    true
  end

  def confirm?
    party? && user != record.requester
  end

  def complete?
    party?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      # Only bookings where the current user is the model or the photographer.
      scope.where(model_id: user.id).or(scope.where(photographer_id: user.id))
    end
  end

  private

  def party?
    user == record.model || user == record.photographer
  end
end