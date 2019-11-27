Rails.application.routes.draw do

#  root 'static_pages#home'
  root 'products#index'

#  get 'placements/index'
#  get 'placements/show'
  devise_for :users, :controllers => { :registrations => "my_registrations" } # mailer added to default action
  get '/users/', to: 'users#index'

  get '/switch_to/:id', to: 'users#switch_to', as: :switch_user
  get '/suppliers/index'
  get '/managers/index'
  get '/inventories', to: 'inventories#index'
  post '/update_quantity/:id', to: 'products#update_quantity', as:  :update_quantity 
  post '/apply_price_rules(/:id)', to: 'products#apply_price_rules', as:  :apply_price_rules
  get '/reports', to: 'reports#index'

  get '/home', to: 'static_pages#home'
  get '/help', to: 'static_pages#help'
  get '/about', to: 'static_pages#about'
  get '/contact', to: 'static_pages#contact'
  get '/news', to: 'static_pages#news'
  get '/terms', to: 'static_pages#terms'
  get '/privacy', to: 'static_pages#privacy'
  get '/export', to: 'orders#export', as: :export

  resources :products, :clients, :suppliers, :managers, :users, :prices
  resources :orders, only: [:new, :index, :show, :create] do
    resources :placements, only: [:index, :show, :create]
  end

end
