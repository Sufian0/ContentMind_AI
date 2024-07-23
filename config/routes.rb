Rails.application.routes.draw do
  get 'recommendations/index'
  get 'contents/index'
  get 'contents/show'
  # Root route
  root 'contents#index'

  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"

  # Routes for Contents controller
  resources :contents, only: [:index, :show]

  # Routes for Recommendations controller
  resources :recommendations, only: [:index]

  
end
