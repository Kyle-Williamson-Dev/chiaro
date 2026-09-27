Rails.application.routes.draw do
  devise_for :users

  resources :bookings, only: [:index, :show, :new, :create] do
    resources :feedbacks, only: [:new, :create]
    member do
      post :confirm
      post :complete
    end
  end

  root "bookings#index"
end