require "rails_helper"

RSpec.describe "Feedbacks", type: :request do
  let(:model) { User.create!(email: "fbmodel@example.com", password: "password123", role: "model") }
  let(:photographer) { User.create!(email: "fbphoto@example.com", password: "password123", role: "photographer") }
  let(:stranger) { User.create!(email: "fbstranger@example.com", password: "password123", role: "model") }

  describe "POST /bookings/:booking_id/feedbacks" do
    it "allows a party to post feedback while feedback is pending" do
      booking = Booking.create!(model: model, photographer: photographer, requester: model)
      booking.confirm!
      booking.complete!

      sign_in model

      post booking_feedbacks_path(booking), params: {
        feedback: { rating: 5, comment: "Great to work with, very professional." }
      }

      expect(response).to redirect_to(booking_path(booking))
      expect(booking.feedbacks.count).to eq(1)
    end

    it "blocks someone not on the booking from posting feedback" do
      booking = Booking.create!(model: model, photographer: photographer, requester: model)
      booking.confirm!
      booking.complete!

      sign_in stranger

      post booking_feedbacks_path(booking), params: {
        feedback: { rating: 5, comment: "I was not part of this shoot." }
      }

      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq("You're not authorized to do that.")
      expect(booking.feedbacks.count).to eq(0)
    end

    it "blocks feedback before the booking is complete" do
      booking = Booking.create!(model: model, photographer: photographer, requester: model)
      # still just "requested" — never confirmed or completed

      sign_in model

      post booking_feedbacks_path(booking), params: {
        feedback: { rating: 5, comment: "Trying to leave feedback too early." }
      }

      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq("You're not authorized to do that.")
    end

    it "blocks posting feedback twice from the same person" do
      booking = Booking.create!(model: model, photographer: photographer, requester: model)
      booking.confirm!
      booking.complete!

      sign_in model

      post booking_feedbacks_path(booking), params: {
        feedback: { rating: 5, comment: "First time posting feedback here." }
      }
      expect(booking.feedbacks.count).to eq(1)

      post booking_feedbacks_path(booking), params: {
        feedback: { rating: 4, comment: "Trying to post a second time." }
      }

      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq("You're not authorized to do that.")
      expect(booking.feedbacks.count).to eq(1)
    end

    it "credits the booking once both sides have posted feedback" do
      booking = Booking.create!(model: model, photographer: photographer, requester: model)
      booking.confirm!
      booking.complete!

      sign_in model
      post booking_feedbacks_path(booking), params: {
        feedback: { rating: 5, comment: "Great to work with." }
      }

      sign_in photographer
      post booking_feedbacks_path(booking), params: {
        feedback: { rating: 5, comment: "Very professional and on time." }
      }

      expect(booking.reload.status).to eq("credited")
    end
  end
end