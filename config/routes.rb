Rails.application.routes.draw do
  resource :session
  resources :passwords, param: :token
  resource :verificacion, only: %i[new create]
  resource :cuenta, only: :show do
    post :activar_dos_pasos
    delete :desactivar_dos_pasos
  end

  root "inicio#show"

  resources :colaboradores, only: %i[index show new create edit update]
  resources :importaciones, only: %i[new create] do
    get :plantilla, on: :collection
  end

  get "ausencias", to: "solicitudes#index", as: :ausencias
  resources :solicitudes, only: %i[new create] do
    member do
      patch :aprobar
      patch :rechazar
      patch :deshacer
    end
  end

  get "auditoria", to: "auditoria#index", as: :auditoria

  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?

  get "up" => "rails/health#show", as: :rails_health_check
end
