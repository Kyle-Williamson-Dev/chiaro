class FeedbacksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_booking

  
  def new
    @feedback = @booking.feedbacks.new
    authorize @feedback
  end

  def create
    @feedback = @booking.feedbacks.new(feedback_params)
    @feedback.author = current_user
    authorize @feedback

    if @feedback.save
      redirect_to @booking, notice: "Feedback submitted"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private 

  def set_booking
    @booking = Booking.find(params[:booking_id])
  end

  def feedback_params
    params.require(:feedback).permit(:rating, :comment, :credited_name)
  end 
end
