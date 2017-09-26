Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  namespace :api do
    namespace :v1 do
      get '/login', to: 'auth#spotify_request'
      get '/me', to: 'users#me'
      # resources :concerts, only: [:show]
      get '/concerts/:artist', to: "concerts#search"
      resources :users, only: [:create]

    end
  end
end
