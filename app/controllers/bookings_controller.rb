class BookingsController < ApplicationController
  before_action :authenticate_user!

  rescue_from AASM::InvalidTransition do
    redirect_to @booking, alert: "That action isn't available for this booking right now."
  end

  def index
    @bookings = policy_scope(Booking)
  end

  def show
    @booking = Booking.find(params[:id])
    authorize @booking
  end

  def new
    @booking = Booking.new
    authorize @booking
  end

  def create
    authorize Booking
    
    @booking = Booking.new(booking_params)
    if current_user.photographer_role?
      @booking.photographer = current_user
    else
      @booking.model = current_user
    end

    @booking.requester = current_user
    
    if @booking.save
      redirect_to @booking, notice: "Booking requested."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def confirm
    @booking = Booking.find(params[:id])
    authorize @booking
    @booking.confirm!
    redirect_to @booking, notice: "Booking confirmed."
  end

  def complete
    @booking = Booking.find(params[:id])
    authorize @booking
    @booking.complete!
    redirect_to @booking, notice: "Booking marked complete. Feedback is now required from both sides."
  end

  private

  def booking_params
    params.require(:booking).permit(:model_id, :photographer_id)
  end
end
