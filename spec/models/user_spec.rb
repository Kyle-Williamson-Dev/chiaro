require "rails_helper"

RSpec.describe User do
  it "has pending feedback until they post their side" do
    model = User.create!(email: "m2@example.com", password: "password123", role: :model)
    photographer = User.create!(email: "p2@example.com", password: "password123", role: :photographer)
    booking = Booking.create!(model: model, photographer: photographer, requester: model)
    booking.confirm!
    booking.complete!

    expect(model.has_pending_feedback?).to eq(true)

    Feedback.create!(booking: booking, author: model, rating: 5, comment: "Great to work with.")

    expect(model.reload.has_pending_feedback?).to eq(false)
  end

  it "stops owing feedback once they file a safety report" do
    model = User.create!(email: "sr-m@example.com", password: "password123", role: :model)
    photographer = User.create!(email: "sr-p@example.com", password: "password123", role: :photographer)
    booking = Booking.create!(model: model, photographer: photographer, requester: model)
    booking.confirm!
    booking.complete!

    SafetyReport.create!(booking: booking, reporter: model, body: "I felt unsafe during the shoot.")

    expect(model.has_pending_feedback?).to be false
    expect(photographer.has_pending_feedback?).to be true
  end
end