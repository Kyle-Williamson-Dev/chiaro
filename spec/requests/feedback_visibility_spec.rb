require "rails_helper"

RSpec.describe "Feedback visibility", type: :request do
  let(:model)        { User.create!(email: "vis-m@example.com", password: "password123", role: :model) }
  let(:photographer) { User.create!(email: "vis-p@example.com", password: "password123", role: :photographer) }
  let(:booking) do
    Booking.create!(model: model, photographer: photographer, requester: model).tap do |b|
      b.confirm!
      b.complete!
    end
  end

  before do
    Feedback.create!(booking: booking, author: model, rating: 5, comment: "Model side of the story")
  end

  it "hides the first feedback from the other party" do
    sign_in photographer
    get booking_path(booking)
    expect(response.body).not_to include("Model side of the story")
  end

  it "shows your own feedback back to you" do
    sign_in model
    get booking_path(booking)
    expect(response.body).to include("Model side of the story")
  end

  it "reveals both once both have posted" do
    Feedback.create!(booking: booking, author: photographer, rating: 4, comment: "Photographer side of the story")
    sign_in photographer
    get booking_path(booking)
    expect(response.body).to include("Model side of the story")
  end
end