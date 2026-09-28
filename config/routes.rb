Rails.application.routes.draw do
  devise_for :users

  resources :bookings, only: [:index, :show, :new, :create] do
    resources :feedbacks, only: [:new, :create]
    member do
      post :confirm
      post :complete
    end
  end

  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?
  
  root "bookings#index"
end