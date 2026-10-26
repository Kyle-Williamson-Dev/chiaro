# Public pages. chiaro.com lands here.
class PagesController < ApplicationController
  layout "landing"

  # Safe whether or not ApplicationController defines these callbacks.
  skip_before_action :authenticate_user!, raise: false
  skip_after_action :verify_authorized, raise: false

  def home
    # Members skip the pitch and go straight to their bookings.
    redirect_to bookings_path if user_signed_in?
  end
end
