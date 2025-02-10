Rails.application.routes.draw do
  devise_for :users
  root to: "pages#home"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
  # reasources :events, only: [:create, :new]
  get "invite_link", to: "invites#invite_link"
  get "organizations/join", to: "invites#token_validation"
  post "organizations/verify_token", to: "invites#verify_token"

  resources :organizations, only: [:show, :index, :new, :create] do
    get :invite, on: :member
  end


end
