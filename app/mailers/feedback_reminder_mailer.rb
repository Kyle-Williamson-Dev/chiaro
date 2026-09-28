class FeedbackReminderMailer < ApplicationMailer
  def reminder
    @booking = params[:booking]
    @user = params[:user]
    @other = @booking.model == @user ? @booking.photographer : @booking.model

    mail to: @user.email,
         subject: "How did your session with #{@other.email} go?"
  end
end