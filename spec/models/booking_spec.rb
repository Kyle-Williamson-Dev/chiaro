require "rails_helper"

RSpec.describe Booking do
  it "credits only after both sides give feedback" do
    model = User.create!(email: "m@example.com", password: "password123", role: :model)
    photographer = User.create!(email: "p@example.com", password: "password123", role: :photographer)
    booking = Booking.create!(model: model, photographer: photographer)

    booking.confirm!
    booking.complete!
    expect(booking.status).to eq("feedback_pending")

    Feedback.create!(booking: booking, author: model, rating: 5, comment: "Great to work with.")
    expect(booking.reload.status).to eq("feedback_pending")

    Feedback.create!(booking: booking, author: photographer, rating: 5, comment: "Very professional.")
    expect(booking.reload.status).to eq("credited")
  end
end