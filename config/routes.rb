Rails.application.routes.draw do

#  root 'static_pages#home'
  root 'products#index'

  devise_for :users, controllers: { registrations: "my_registrations" } 
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

  post '/add_product(/:id)', to: 'placements#add_product', as: :add_product
  get '/cart', to: 'placements#cart', as: :cart
#  get '/send_client_mail(/:id)', to: 'client_mails#send_client_mail', as: :send_client_mail
#  get '/preview_mail(/:id)', to: 'client_mails#preview_mail', as: :preview_mail
#  get '/client_mail_target(/:id)', to: 'client_mails#show_target', as: :client_mail_target

  resources :products, :clients, :suppliers, :managers, :users, :prices, :reports
  resources :orders, only: [:new, :index, :show, :create] do
    resources :placements, only: [:index, :show, :create]
  end

  resources :client_mails do
    get 'show_target', on: :member
    get 'send_all', on: :member
  end


end
