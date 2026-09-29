require "rails_helper"

RSpec.describe "Profiles", type: :request do
  let(:user)  { User.create!(email: "prof-m@example.com", password: "password123", role: :model) }
  let(:other) { User.create!(email: "prof-p@example.com", password: "password123", role: :photographer) }

  it "creates a profile on signup" do
    expect(user.profile).to be_present
  end

  it "redirects signed-out visitors" do
    get profile_path(user.profile)
    expect(response).to redirect_to(new_user_session_path)
  end

  it "lets a member view another profile" do
    sign_in user
    get profile_path(other.profile)
    expect(response).to have_http_status(:ok)
  end

  it "updates only your own profile" do
    sign_in user
    patch my_profile_path, params: { profile: { display_name: "New Name" } }
    expect(user.profile.reload.display_name).to eq("New Name")
    expect(other.profile.reload.display_name).not_to eq("New Name")
  end
end