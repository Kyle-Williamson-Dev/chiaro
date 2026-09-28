# Preview all emails at http://localhost:3000/rails/mailers/feedback_reminder_mailer
class FeedbackReminderMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/feedback_reminder_mailer/reminder
  def reminder
    FeedbackReminderMailer.reminder
  end

end
