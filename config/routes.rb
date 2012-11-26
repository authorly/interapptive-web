Interapptive::Application.routes.draw do

  root :to => 'home#index', :constraints => lambda { |request| request.cookies['auth_token'] }
  root :to => 'user_sessions#new'

  get 'assets/index', :as => :assets

  get  'users/sign_up'   => 'users#new',             :as => 'sign_up'
  get  'users/sign_in'   => 'user_sessions#new',     :as => 'sign_in'
  post 'users/sign_in'   => 'user_sessions#create',  :as => ''
  match 'users/sign_out' => 'user_sessions#destroy', :as => 'sign_out'
  get  'users/settings'  => 'users#edit'

  resources :users, :except => [:new, :edit, :index] do 
    resources :fonts
  end
  
  get  'password_reset'      => 'password_resets#new',   :as => :new_password_reset
  get  'password_resets/:id' => 'password_resets#edit',  :as => :edit_password_reset
  put  'password_resets/:id' => 'password_resets#update'
  post 'password_resets'     => 'password_resets#create'

  get 'simulator' => 'simulator#index', :as => 'simulator'
  resource :compiler

  resources :images
  resources :videos
  resources :sounds
  resources :fonts

  #resources :actions do
    #resources :attributes

    #collection do
      #get 'definitions'
    #end

    #member do
      #get 'attributes'
    #end
  #end

  resources :storybooks do
    resources :scenes do
      resources :images
      resources :videos
      resources :sounds
      resources :fonts

      collection { post :sort }
    end

    resources :fonts
    resources :images
    resources :videos
    resources :sounds

    resource  :icon, :controller => :storybook_icons
  end

  resources :scenes do
    #resources :actions

    resources :keyframes do
      collection { post :sort }
    end
  end

  resources :keyframes do
    resources :texts, :controller => :keyframe_texts
  end

  resource :zencoder, :controller => :zencoder, :only => :create
end
