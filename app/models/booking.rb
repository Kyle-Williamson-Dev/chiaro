class Booking < ApplicationRecord
  include AASM

  belongs_to :model, class_name: "User"
  belongs_to :photographer, class_name: "User"
  belongs_to :requester, class_name: "User", optional: true
  validates :requester, presence: true, on: :create
  validate :parties_have_correct_roles
  has_many :feedbacks, dependent: :destroy

  enum :status, {
    requested: 0,
    confirmed: 1,
    completed: 2,
    feedback_pending: 3,
    credited: 4,
    disputed: 5
  }

  aasm column: :status, enum: true do
    state :requested, initial: true
    state :confirmed
    state :completed
    state :feedback_pending
    state :credited
    state :disputed

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
  end

  def both_sides_gave_feedback?
    feedbacks.where(author_id: model_id).exists? &&
      feedbacks.where(author_id: photographer_id).exists?
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