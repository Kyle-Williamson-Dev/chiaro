require "rails_helper"

RSpec.describe Booking do
  it "credits only after both sides give feedback" do
    model = User.create!(email: "m@example.com", password: "password123", role: :model)
    photographer = User.create!(email: "p@example.com", password: "password123", role: :photographer)
    booking = Booking.create!(model: model, photographer: photographer, requester: model)

    booking.confirm!
    booking.complete!
    expect(booking.status).to eq("feedback_pending")

    Feedback.create!(booking: booking, author: model, rating: 5, comment: "Great to work with.")
    expect(booking.reload.status).to eq("feedback_pending")

    Feedback.create!(booking: booking, author: photographer, rating: 5, comment: "Very professional.")
    expect(booking.reload.status).to eq("credited")
  end

  it "rejects a second feedback from the same author at the database level" do
    model = User.create!(email: "dup-m@example.com", password: "password123", role: :model)
    photographer = User.create!(email: "dup-p@example.com", password: "password123", role: :photographer)
    booking = Booking.create!(model: model, photographer: photographer, requester: model)
    booking.confirm!
    booking.complete!

    Feedback.create!(booking: booking, author: model, rating: 5, comment: "Great session, very professional.")

    expect {
      Feedback.create!(booking: booking, author: model, rating: 4, comment: "Submitting this a second time.")
    }.to raise_error(ActiveRecord::RecordNotUnique)
  end

  it "rejects a photographer who doesn't have the photographer role" do
    model = User.create!(email: "role-m@example.com", password: "password123", role: :model)
    other_model = User.create!(email: "role-m2@example.com", password: "password123", role: :model)
    booking = Booking.new(model: model, photographer: other_model, requester: model)

    expect(booking).not_to be_valid
    expect(booking.errors[:photographer]).to be_present
  end
end