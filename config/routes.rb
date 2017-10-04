Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  namespace :api do
    namespace :v1 do
      get '/login', to: 'auth#spotify_request'
      get '/me', to: 'users#me'
      get '/users/:user/concerts', to: 'concerts#show'
      post '/users/:user/concerts/:concert', to: 'concerts#add'
      delete '/users/:user/concerts/:concert', to: 'concerts#remove'
      get '/concerts/:artist', to: "concerts#search"
      post '/concerts', to: 'concerts#index'
      get '/geocode/:geo', to: 'users#geo'
      resources :users, only: [:create]

    end
  end
end
