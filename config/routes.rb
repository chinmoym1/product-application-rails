Rails.application.routes.draw do
  devise_for :users
  
  root "products#index" 

  resources :products do
    # resources :product_vendors, only: [:create, :destroy]
    resources :stocks, only: [:new, :create, :destroy]
  end

  resources :vendors
  resources :stocks
  resources :orders
  resources :customers
    
  # get 'products/index'
  # get 'products/show'
  # get 'products/new'
  # get 'products/edit'
  # get 'vendors/all'

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
