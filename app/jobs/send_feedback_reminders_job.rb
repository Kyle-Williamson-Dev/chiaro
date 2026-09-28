class SendFeedbackRemindersJob < ApplicationJob
  queue_as :default

  REMINDER_DAYS = [3, 7, 14]

  def perform
    dates = REMINDER_DAYS.map { |n| n.days.ago.to_date }

    Booking.feedback_pending.where("completed_at::date IN (?)", dates).find_each do |booking|
      [booking.model, booking.photographer].each do |user|
        next if booking.feedbacks.exists?(author_id: user.id)

        FeedbackReminderMailer.with(booking: booking, user: user).reminder.deliver_now
      end
    end
  end
end