class ProfilesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_own_profile, only: [:edit, :update]

  def show
    @profile = Profile.find(params[:id])
    authorize @profile
    @credits = @profile.user.credited_bookings
                       .includes(model: :propfile, photographer: :profile)
  end

  def edit; end

  def update
    new_images = Array(params.dig(:profile, :portfolio_images)).compact_blank

    if @profile.update(profile_params)
      @profile.profile_images.attach(new_images) if new_images.any?
      redirect_to profile_path(@profile), notice: "Profile updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_own_profile
    @profile = current_user.profile
    authorize @profile
  end

  def profile_params
        params.require(:profile).permit(:display_name, :bio, :city, :instagram,
                                    :boundaries, :avatar, shoot_types: [])
  end
end
