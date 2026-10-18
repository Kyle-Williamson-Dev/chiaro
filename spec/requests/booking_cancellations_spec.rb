require "rails_helper"

RSpec.describe "Booking cancellations", type: :request do
  let(:model)        { User.create!(email: "can-m@example.com", password: "password123", role: :model) }
  let(:photographer) { User.create!(email: "can-p@example.com", password: "password123", role: :photographer) }
  let(:outsider)     { User.create!(email: "can-o@example.com", password: "password123", role: :photographer) }
  let(:booking)      { Booking.create!(model: model, photographer: photographer, requester: model) }

  it "lets the requester withdraw a request" do
    sign_in model
    post cancel_booking_path(booking), params: { cancel_reason: "changed_plans" }

    booking.reload
    expect(booking).to be_cancelled
    expect(booking.cancelled_by).to eq(model)
    expect(booking.cancel_reason).to eq("changed_plans")
  end

  it "lets the other party cancel a confirmed booking as a no-show" do
    booking.confirm!
    sign_in photographer
    post cancel_booking_path(booking), params: { cancel_reason: "no_show" }

    booking.reload
    expect(booking).to be_cancelled
    expect(booking.cancel_reason).to eq("no_show")
  end

  it "blocks outsiders" do
    sign_in outsider
    post cancel_booking_path(booking), params: { cancel_reason: "other" }

    expect(response).to redirect_to(root_path)
    expect(booking.reload).to be_requested
  end

  it "won't cancel a booking that's already completed" do
    booking.confirm!
    booking.complete!
    sign_in model
    post cancel_booking_path(booking), params: { cancel_reason: "other" }

    expect(booking.reload).to be_feedback_pending
  end

  it "doesn't leave anyone owing feedback" do
    booking.confirm!
    booking.cancel_by!(model, reason: "changed_plans")

    expect(model.has_pending_feedback?).to be(false)
    expect(photographer.has_pending_feedback?).to be(false)
  end
end