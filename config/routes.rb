Rails.application.routes.draw do
  devise_for :users, path: '', path_names: {
    sign_in: 'login',
    sign_out: 'logout',
    registration: 'signup',
},
  controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations',
    passwords: 'users/passwords',
  }

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "bookings#index"

  namespace :api do
    namespace :v1 do
      resources :users, only: [] do
        patch :update_avatar, on: :member # PATCH /api/v1/users/:id/avatar
        delete :destroy_avatar, on: :member # NEW: Route for deleting avatar
        get :confirm_email, on: :member # GET /api/v1/users/:id/confirm_email
        collection do
          get 'current' #GET /api/v1/users/current
          get 'permissions', to: 'users#user_permissions' # GET /api/v1/users/permissions
        end
      end

      get 'bookings/monthly_counts', to: 'bookings#monthly_counts'
      get 'bookings/all', to: 'bookings#all'

      post 'subscriptions/create_payment_url', to: 'subscriptions#create_payment_url'
      post 'payfast/itn', to: 'payfast#itn' # This is your IPN endpoint
      
      resources :clients, only: [:index, :show, :new, :create, :update, :destroy]
      resources :bookings, only: [:index, :show, :create, :update, :destroy]
      resources :settings, only: [:index, :show, :create, :update]
    end
  end

  namespace :admin do
    resources :dashboard, only: [:index]
  end
end
