class Profile < ApplicationRecord
  SHOOT_TYPES  = %w[boudoir fine_art_nude implied portrait].freeze

  belongs_to :user
  has_one_attached :avatar
  has_many_attached :portfolio_images

  before_validation { self.shoot_types = Array(shoot_types).compact_blank }

  validates :display_name, presence: true, length: { maximum: 60 }
  validates :bio, length: { maximum: 1000 }
  validate :shoot_types_are_known

  private

  def shoot_types_are_known
    unknown = shoot_types - SHOOT_TYPES
    errors.add(:shoot_types, "contain uknown values: #{unknown.join(', ')}") if unknown.any?
  end
end
