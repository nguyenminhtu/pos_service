Rails.application.routes.draw do
  namespace :api, defaults: { format: JSON }  do
    namespace :v1 do
      post 'login', to: 'authentications#create'

      resources :users

      namespace :import do
        resources :products, only: :create
      end
    end
  end
end
