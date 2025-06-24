Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  get 'index', to: 'public#public'
  get 'private', to: 'private#private'
  get 'scoped', to: 'private#private_scoped'
  namespace :api do
    namespace :v1 do
      get 'auth/auth0/callback', to: 'auth0#callback'
      get 'auth/failure', to: 'auth0#failure'
      delete 'logout', to: 'auth0#logout'
      resources :companies, only: [:create, :show, :index, :update] do
        resources :users, only: [:create, :show, :index, :update, :destroy]
      end
      scope :payments do 
        post '/create_preference', to: 'payments#create_preference'
        post '/subscription', to: 'payments#create_subscription'
        post '/webhook', to: 'payments#webhook'
      end
    end
  end
end
