Rails.application.routes.draw do
  root "prompts#index"

  resources :categories, except: [:show]
  resources :prompts do
    member do
      post :toggle_favorite
      post :execute
      get :versions
      post :restore_version
    end
  end
  resources :ai_providers
  resources :executions, only: [:index, :show, :destroy]

  get "up" => "rails/health#show", as: :rails_health_check
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
end
