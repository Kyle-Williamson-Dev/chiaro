Rails.application.routes.draw do
  devise_for :users

  resources :workshops, only: [:index, :show, :new, :create, :edit, :update] 
  resources  :profile,  only: [:edit, :update], as: :my_profile
  resources :profiles, only: [:show]           # /profiles/:id, which is anyone's
  resources :bookings, only: [:index, :show, :new, :create] do
    resources :feedbacks, only: [:new, :create]
    member do
      post :confirm
      post :complete
      post :cancel
    end
  end

  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?
  
  root "pages#home"
end