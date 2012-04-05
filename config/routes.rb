Interapptive::Application.routes.draw do
  get "media/index", :as => :media

  root :to => "home#index"
end
