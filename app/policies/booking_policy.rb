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

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.where(model_id: user.id).or(scope.where(photographer_id: user.id))
      #This makes policy_scope(Booking) only return bookings where the current user 
      # is either the model or the photographer. Nobody sees anyone 
      # else's bookings in a list.
    end
  end
end