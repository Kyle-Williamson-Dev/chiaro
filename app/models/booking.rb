class Booking < ApplicationRecord
  include AASM

  belongs_to :model, class_name: "User"
  belongs_to :photographer, class_name: "User"
  belongs_to :requester, class_name: "User", optional: true
  belongs_to :cancelled_by, class_name: "User", optional: true
  validates :requester, presence: true, on: :create
  validate :parties_have_correct_roles
  has_many :feedbacks, dependent: :destroy
  has_many :safety_reports, dependent: :destroy

  enum :status, {
    requested: 0,
    confirmed: 1,
    completed: 2,
    feedback_pending: 3,
    credited: 4,
    disputed: 5,
    cancelled: 6
  }

  enum :cancel_reason, { changed_plans: 0, no_response: 1, no_show: 2, other: 3 }, prefix: :cancelled_for

  aasm column: :status, enum: true do
    state :requested, initial: true
    state :confirmed
    state :completed
    state :feedback_pending
    state :credited
    state :disputed
    state :cancelled

    event :confirm do
      transitions from: :requested, to: :confirmed
    end

    event :complete do
      transitions from: :confirmed, to: :feedback_pending
      after do
        update(completed_at: Time.current)
      end
    end

    event :credit do
      transitions from: :feedback_pending, to: :credited,
        guard: :both_sides_gave_feedback?
    end

    event :dispute do
      transitions from: [:confirmed, :feedback_pending], to: :disputed
    end

    event :resolve_dispute do
      transitions from: :disputed, to: :feedback_pending
    end

    event :cancel do
      transitions from: [:requested, :confirmed], to: :cancelled
    end
  end

  def both_sides_gave_feedback?
    feedbacks.where(author_id: model_id).exists? &&
      feedbacks.where(author_id: photographer_id).exists?
  end

  def awaiting_feedback_from?(user)
    !feedbacks.exists?(author_id: user.id) &&
      !safety_reports.exists?(reporter_id: user.id)
  end

  def feedback_revealed?
    feedbacks.distinct.count(:author_id) >= 2
  end

  def visible_feedbacks_for(user)
    return feedbacks if feedback_revealed? || user.admin_role?
    feedbacks.where(author: user)
  end

  def cancel_by!(user, reason:)
    assign_attributes(cancelled_by: User, cancel_reason: reason, cancelled_at: Time.current)
    cancel!
  end

  private

  def parties_have_correct_roles
    if model && !model.model_role?
      errors.add(:model, "must be a model")
    end
    if photographer && !photographer.photographer_role?
      errors.add(:photographer, "must be a photographer")
    end
  end
end