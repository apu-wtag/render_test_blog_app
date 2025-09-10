require 'sidekiq/web'
Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check
  # sidekiq
  mount Sidekiq::Web => '/sidekiq'
  # signup routes
  get "sign_up",to: "users#new"
  post "sign_up", to: "users#create"
  resources :users, only: [ :show, :edit, :update] do
    collection do
      get :check_username
    end
  end
  # login routes
  get "login", to: "sessions#new"
  post "login", to: "sessions#create"
  delete "logout", to: "sessions#destroy"

  # password reset routes
  resources :password_resets, only: [:new, :create, :edit, :update,]

  # article resources
  resources :articles do
    member do
      post :toggle_clap
    end
    collection do
      post :upload_image
      post :fetch_image_url
      post :upload_file
    end
  end

  # dashboard
  root "articles#index"
end
