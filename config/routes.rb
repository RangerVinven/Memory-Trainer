Rails.application.routes.draw do
  resources :pao_numbers, only: [:index] do
    collection do
      patch :bulk_update
    end
  end

  resources :pao_digits, only: [] do
    collection do
      patch :bulk_update
    end
  end

  resources :pao_cards, only: [:index] do
    collection do
      patch :bulk_update
    end
  end

  resources :memory_palaces do
    resources :loci, only: [:create, :update, :destroy] do
      member do
        patch :move
      end
    end
  end

  resources :training_sessions, only: [:index, :new, :create, :show, :update]
  get "pages/home"
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  root "pages#home"

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
