require 'rails_helper'

RSpec.describe SendFeedbackRemindersJob, type: :job do
  let(:model)         { User.create!(email: "rem-m@example.com", password: "password123", role: :model) }
  let(:photographer) { User.create!(email: "rem-p@example.com", password: "password123", role: :photographer) }
  let(:booking) do
    Booking.create!(model: model, photographer: photographer, requester: model).tap do |b|
      b.confirm!
      b.complete!
    end
  end

  before { ActionMailer::Base.deliveries.clear }

  it "reminds only the party who still owes feedback on a reminder day" do
    booking.update!(completed_at: 3.days.ago)
    Feedback.create!(booking: booking, author: photographer, rating: 5, comment: "Great session, thank you.")

    described_class.perform_now

    expect(ActionMailer::Base.deliveries.flat_map(&:to)).to eq([model.email])
  end

  it "sends nothing on a non-reminder day" do
    booking.update!(completed_at: 4.days.ago)

    described_class.perform_now

    expect(ActionMailer::Base.deliveries).to be_empty
  end

  it "doesn't remind someone who filed a safety report" do
    booking.update!(completed_at: 3.days.ago)
    SafetyReport.create!(booking: booking, reporter: model, body: "Something happened I need to report.")
    Feedback.create!(booking: booking, author: photographer, rating: 5, comment: "Great session, thank you.")

    described_class.perform_now

    expect(ActionMailer::Base.deliveries).to be_empty
  end
end