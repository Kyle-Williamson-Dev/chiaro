require "rails_helper"

RSpec.describe "Booking transitions", type: :request do
  let(:model)        { User.create!(email: "m@example.com", password: "password123", role: :model) }
  let(:photographer) { User.create!(email: "p@example.com", password: "password123", role: :photographer) }
  let(:outsider)     { User.create!(email: "o@example.com", password: "password123", role: :photographer) }
  let(:booking)      { Booking.create!(model: model, photographer: photographer, requester: model) }

  describe "confirm" do
    it "blocks the requester from confirming their own booking" do
      sign_in model
      post confirm_booking_path(booking)
      expect(booking.reload).to be_requested
    end

    it "lets the other party confirm" do
      sign_in photographer
      post confirm_booking_path(booking)
      expect(booking.reload).to be_confirmed
    end

    it "blocks outsiders" do
      sign_in outsider
      post confirm_booking_path(booking)
      expect(booking.reload).to be_requested
    end
  end

  describe "complete" do
    before { booking.confirm! }

    it "lets either party complete" do
      sign_in model
      post complete_booking_path(booking)
      expect(booking.reload).not_to be_confirmed
    end

    it "blocks outsiders" do
      sign_in outsider
      post complete_booking_path(booking)
      expect(booking.reload).to be_confirmed
    end
  end
end