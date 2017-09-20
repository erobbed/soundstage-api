Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  namespace :api do
    namespace :v1 do
      get '/login', to: 'auth#spotify_request'
      resources :users, only: [:create]
      # get '/auth/spotify/callback' to: 'auth#create'
    end
  end
end
