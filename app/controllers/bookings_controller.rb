class BookingsController < ApplicationController
  before_action :authenticate_user!

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

    if @booking.save
      redirect_to @booking, notice: "Booking requested."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def confirm
    @booking = Booking.find(params[:id])
    authorize @booking, :show?
    @booking.confirm!
    redirect_to @booking, notice: "Booking confirmed."
  end

  def complete
    @booking = Booking.find(params[:id])
    authorize @booking, :show?
    @booking.complete!
    redirect_to @booking, notice: "Booking marked complete. Feedback is now required from both sides."
  end

  private

  def booking_params
    params.require(:booking).permit(:model_id, :photographer_id)
  end
end
