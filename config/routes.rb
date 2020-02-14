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
  get '/empty_cart', to: 'placements#empty_cart', as: :empty_cart
  get '/delete_product(/:id)', to: 'placements#delete_product', as: :delete_product
  post '/update_product_qty(/:id)', to: 'placements#update_product_qty', as: :update_product_qty

  get '/self_test', to: 'self_test#index', as: :self_test

  resources :products,  :suppliers, :managers, :users, :prices, :table_notes
  resources :orders do
    get 'download_po', on: :member
    get 'download_invoice', on: :member
    resources :placements, only: [:index, :show, :create] 
  end
  resources :clients do
    get 'send_invite_to_register', on: :member
  end 

  resources :reports  do
     get 'download', on: :member
     get 'export', on: :member
  end

  resources :client_mails do
    get 'show_target', on: :member  # show target clients in client mailer
    get 'send_all', on: :member
    get 'send_staff', on: :member
  end

end
