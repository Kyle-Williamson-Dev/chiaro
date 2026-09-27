require 'rails_helper'

RSpec.describe "Bookings", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/bookings/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get "/bookings/show"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /new" do
    it "returns http success" do
      get "/bookings/new"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /create" do
    it "returns http success" do
      get "/bookings/create"
      expect(response).to have_http_status(:success)
    end
  end

end
