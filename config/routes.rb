Rails.application.routes.draw do

  root 'static_pages#home'
#  root 'products#index'

  devise_for :users, controllers: { registrations: "my_registrations" } 
  get '/users/', to: 'users#index'
  get '/switch_to/:id', to: 'users#switch_to', as: :switch_user
  get '/suppliers/index'
  get '/managers/index'
  get '/inventories', to: 'inventories#index'
  post '/update_stock/:id', to: 'products#update_stock', as:  :update_stock 
  post '/update_delta/:id', to: 'products#update_delta', as:  :update_delta 
  post '/apply_price_rules(/:id)', to: 'products#apply_price_rules', as:  :apply_price_rules
  get '/reports', to: 'reports#index'

  get '/home', to: 'static_pages#home'
  get '/help', to: 'static_pages#help'
  get '/about', to: 'static_pages#about'
  get '/contact', to: 'static_pages#contact'
  get '/news', to: 'static_pages#news'
  get '/terms', to: 'static_pages#terms'
  get '/privacy', to: 'static_pages#privacy'
  
  post '/add_product(/:id)', to: 'placements#add_product', as: :add_product
  get '/cart', to: 'placements#cart', as: :cart
  get '/empty_cart', to: 'placements#empty_cart', as: :empty_cart
  get '/delete_product(/:id)', to: 'placements#delete_product', as: :delete_product
  post '/update_product_qty(/:id)', to: 'placements#update_product_qty', as: :update_product_qty

  get '/image_upload', to: 'products#image_upload'
  post '/upload_image', to: 'products#upload_image'

  get '/self_test', to: 'self_test#index', as: :self_test

  resources :suppliers, :managers, :shippers, :users, :prices, :table_notes
  resources :products do
    get 'show_pending_orders', on: :member 
    get 'show_active_orders', on: :member 
#    post 'clear_active_order', on: :member
    post 'set_pending_orders_to_shipped', on: :member
    get 'disable', on: :member
    resources :ppos, only: [:index, :show, :create, :destroy] 
  end

# extra ppo paths  
  resources :ppos, only: [:index, :show, :create] do
    get 'show_placements', on: :member 
    post 'set_to_shipped', on: :member
    get 'export', on: :member
    get 'download', on: :member
  end

  resources :'packing_lists' do 
     get 'download', on: :member
     patch 'ship', on: :member
  end

  get '/export_orders', to: 'orders#export' 
  get '/export_ppos', to: 'ppos#export' 

  resources :orders do
    get 'download_po', on: :member
    get 'download_invoice', on: :member
    get 'cancel', on: :member
    patch 'set_to_shipped', on: :member
    resources :placements, only: [:index, :show, :create] do
      patch 'set_to_shipped', on: :member
      get 'set_to_shipped', on: :member  # for redirect_to in placements#update_shipped
      patch 'update_shipped', on: :member
    end
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
