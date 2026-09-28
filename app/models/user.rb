class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum :role, { model: 0, photographer: 1, admin: 2 }, suffix: true

  before_validation :prevent_self_signup_as_admin, on: :create

  has_many :portfolio_images, dependent: :destroy
  has_many :bookings_as_model, class_name: "Booking", foreign_key: :model_id
  has_many :bookings_as_photographer, class_name: "Booking", foreign_key: :photographer_id

  def bookings_awaiting_feedback
    Booking.feedback_pending
           .where("model_id = :id OR photographer_id = :id", id: id)
           .where.not(id: Feedback.where(author_id: id).select(:booking_id))
  end

  def has_pending_feedback?
    bookings_awaiting_feedback.exists?
  end

  private

  def prevent_self_signup_as_admin
    self.role = "model" if role == "admin"
  end
end