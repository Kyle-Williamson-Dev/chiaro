require "rails_helper"

RSpec.describe "Bookings", type: :request do
  let(:model) { User.create!(email: "reqmodel@example.com", password: "password123", role: "model") }
  let(:photographer) { User.create!(email: "reqphoto@example.com", password: "password123", role: "photographer") }
  let(:stranger) { User.create!(email: "reqstranger@example.com", password: "password123", role: "model") }

  describe "GET /bookings/:id" do
    it "allows a party to the booking to view it" do
      booking = Booking.create!(model: model, photographer: photographer, requester: model)
      sign_in model

      get booking_path(booking)

      expect(response).to have_http_status(:ok)
    end

    it "blocks someone not on the booking" do
      booking = Booking.create!(model: model, photographer: photographer, requester: model)
      sign_in stranger

      get booking_path(booking)

      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq("You're not authorized to do that.")
    end

    it "redirects to sign in if nobody is logged in" do
      booking = Booking.create!(model: model, photographer: photographer, requester: model)

      get booking_path(booking)

      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "POST /bookings" do
    it "allows a booking request when there's no pending feedback" do
      sign_in model

      post bookings_path, params: { booking: { photographer_id: photographer.id } }

      expect(response).to redirect_to(Booking.last)
    end

    it "blocks a new booking if the user has pending feedback" do
      old_booking = Booking.create!(model: model, photographer: photographer, requester: model)
      old_booking.confirm!
      old_booking.complete!
      # model has NOT posted feedback yet, so has_pending_feedback? is true

      sign_in model

      post bookings_path, params: { bookngs: { photogrpaher_id: photographer.id } }

      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq("You're not authorized to do that.")
    end
  end
end