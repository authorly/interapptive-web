Interapptive::Application.routes.draw do
  root :to => 'home#index'

  get 'media/index', :as => :media

  get  'users/sign_up'  => 'users#new',             :as => 'sign_up'
  get  'users/sign_in'  => 'user_sessions#new',     :as => 'sign_in'
  post 'users/sign_in'  => 'user_sessions#create',  :as => ''
  post 'users/sign_out' => 'user_sessions#destroy', :as => 'sign_out'
  get  'users/settings' => 'users#edit'

  resources :users, :except => [:new, :edit]
  
  get  'password_reset'      => 'password_resets#new',   :as => :new_password_reset
  get  'password_resets/:id' => 'password_resets#edit',  :as => :edit_password_reset
  put  'password_resets/:id' => 'password_resets#update'
  post 'password_resets'     => 'password_resets#create'

  resources :storybooks do
    resources :scenes
  end

  resources :images, :only => [:create, :destroy]
end
