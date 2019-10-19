Rails.application.routes.draw do

  root 'static_pages#home'
  devise_for :users
  get '/users/', to: 'users#index'
  get '/products/index(/:id)' => 'products#find', constraints: { query_string: /findstr/ }
  get '/products/index'
  get '/reports', to: 'reports#index'
  get '/inventories', to: 'inventories#index'

  get '/home', to: 'static_pages#home'
  get '/help', to: 'static_pages#help'
  get '/about', to: 'static_pages#about'
  get '/contact', to: 'static_pages#contact'
  get '/news', to: 'static_pages#news'
  get '/terms', to: 'static_pages#terms'
  get '/privacy', to: 'static_pages#privacy'

  resources :products, :clients, :orders, :users, :inventories
end
