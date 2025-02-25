Rails.application.routes.draw do
  devise_for :users
  root to: "pages#home"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
  post "events/:id/ai_tasks", to: "tasks#create_ai_task", as: :ai_task

  resources :events, only: [:create, :new, :show, :edit, :update] do
    resources :tasks, only: [:create, :update]
      member do
        get 'preview_event_plan'
        post 'save_event_plan'
      end
  end

  patch "user/change_profile_picture", to: "users#change_profile_picture", as: :change_profile_picture

  # reasources :events, only: [:create, :new]
  get "invite_link", to: "invites#invite_link"
  get "organizations/join", to: "invites#join"
  post "organizations/invite_result", to: "invites#invite_result"

  resources :organizations, only: [:show, :index, :new, :create] do
    get :invite, on: :member
  end

  # resources :events, only: [:show]
  get "/authentication/line_callback", to: "authentication#line_callback"

  resources :dashboard, only: [:index] do
    collection do
      get :owned_events
      get :collaborated_events
    end
  end
end
