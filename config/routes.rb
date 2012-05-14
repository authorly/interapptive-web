Interapptive::Application.routes.draw do
  root :to => 'home#index', :constraints => lambda { |request| request.cookies['auth_token'] }
  root :to => 'user_sessions#new'

  get 'assets/index', :as => :assets

  get  'users/sign_up'  => 'users#new',             :as => 'sign_up'
  get  'users/sign_in'  => 'user_sessions#new',     :as => 'sign_in'
  post 'users/sign_in'  => 'user_sessions#create',  :as => ''
  post 'users/sign_out' => 'user_sessions#destroy', :as => 'sign_out'
  get  'users/settings' => 'users#edit'

  resources :users, :except => [:new, :edit, :index]
  
  get  'password_reset'      => 'password_resets#new',   :as => :new_password_reset
  get  'password_resets/:id' => 'password_resets#edit',  :as => :edit_password_reset
  put  'password_resets/:id' => 'password_resets#update'
  post 'password_resets'     => 'password_resets#create'

  resources :images
  resources :videos
  resources :sounds
  resources :fonts

  resources :actions
  resources :touch_zones

  resources :storybooks do
    resources :scenes
  end

  resources :scenes do
    resources :keyframes

    member do
      get 'images'
      get 'touch_zones'
    end
  end

  resources :keyframes do
    resources :texts, :controller => :keyframe_texts
  end
end
