class Workshop < ApplicationRecord
  MIN_CREDITS_TO_HOST = 3
  MAX_CAPACITY = 20

  belongs_to :host, class_name: "User"

  validates :title, presence: true, length: { maximum: 100 }
  validates :description, presence: true, length: { maximum: 2000 }
  validates :shoot_type, inclusion: { in: Profile::SHOOT_TYPES }
  validates :starts_at, :location_area, :address, presence: true
  validates :capacity, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: MAX_CAPACITY }
  validates :price, numericality: { greater_than_or_equal_to: 0 }
  validate :host_must_be_a_model
  validate :starts_in_the_future, on: :create

  scope :upcoming, -> { where("starts_at > ?", Time.current).order(:starts_at) }

  def self.can_host?(user)
    user.model_role? && user.credited_bookings.count >= MIN_CREDITS_TO_HOST
  end

  private

  def host_must_be_a_model
    errors.add(:host, "must be a model") if host && !host.model_role?
  end

  def starts_in_the_future
    errors.add(:starts_at, "must be in the future") if starts_at && starts_at <= Time.current
  end
end