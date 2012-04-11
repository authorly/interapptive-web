Interapptive::Application.routes.draw do
  root :to => "home#index"

  get "media/index", :as => :media

  # Authentication.
  controller :user_sessions do
    get  'account/sign_in'  => :new,     :as => :sign_in_users
    post 'account/sign_in'  => :create,  :as => :sign_in_users
    post 'account/sign_out' => :destroy, :as => :sign_out_users
  end

  get    'account/sign_up'             => 'users#new'
  get    'account/settings'            => 'users#edit'
  put    'account'                     => 'users#update'
  delete 'account'                     => 'users#destroy'
  get    'account/password_reset'      => 'password_resets#new',    :as => :new_password_reset
  get    'account/password_resets/:id' => 'password_resets#edit',   :as => :edit_password_reset
  put    'account/password_resets/:id' => 'password_resets#update'
  post   'account/password_resets'     => 'password_resets#create', :as => :password_resets
end
