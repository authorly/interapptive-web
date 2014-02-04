Interapptive::Application.routes.draw do

  root :to => 'admin::users#index', :constraints => lambda { |request| request.cookies['auth_token'] && request.cookies['is_admin'] }
  root :to => 'storybooks#index', :constraints => lambda { |request| request.cookies['auth_token'] }
  root :to => 'user_sessions#new'

  #get  'users/sign_up'  => 'users#new',             :as => 'sign_up'
  get  'users/sign_in'  => 'user_sessions#new',     :as => 'sign_in'
  post 'users/sign_in'  => 'user_sessions#create',  :as => ''
  match 'users/sign_out' => 'user_sessions#destroy', :as => 'sign_out'
  get  'users/settings'  => 'users#edit'

  resource :user do
    collection { get :show_signed_in_as_user }
  end

  get  'password_reset'      => 'password_resets#new',   :as => :new_password_reset
  get  'password_resets/:id' => 'password_resets#edit',  :as => :edit_password_reset
  put  'password_resets/:id' => 'password_resets#update'
  post 'password_resets'     => 'password_resets#create'

  get 'simulator' => 'simulator#index', :as => 'simulator'

  resource :compiler
  resource :confirmation, only: [:new, :create]
  resource :term,         only: [:new, :create], :path_names => { :new => 'accept' }, :path => 'terms'
  resource :kmetrics,   only: :create

  resources :images
  resources :videos
  resources :sounds
  resources :fonts

  #resources :actions do
    #collection do
      #get 'definitions'
    #end
  #end

  resources :storybooks do
    resources :scenes do
      collection { put :sort }
    end

    resources :fonts
    resources :images
    resources :videos
    resources :sounds
    resources :assets, only: [:create, :index]
  end

  resources :scenes do
    #resources :actions

    resources :keyframes do
      collection { put :sort }
    end
  end

  resources :keyframes

  resource :zencoder, :controller => :zencoder, :only => :create

  namespace :admin do
    resources :users do
      collection do
        get 'search'
      end
      member do
        post 'send_invitation'
        post 'restore'
      end
    end

    resources :storybook_assignments, :only => [:edit, :update]
  end
end
