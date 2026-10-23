Rails.application.routes.draw do
  root "inicio#show"

  resources :colaboradores, only: %i[index show]

  get "ausencias", to: "solicitudes#index", as: :ausencias
  resources :solicitudes, only: %i[new create] do
    member do
      patch :aprobar
      patch :rechazar
      patch :deshacer
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
