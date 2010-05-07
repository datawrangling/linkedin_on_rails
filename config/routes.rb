ActionController::Routing::Routes.draw do |map|
  map.login "login", :controller => "user_sessions", :action => "new"
  map.logout "logout", :controller => "user_sessions", :action => "destroy"
  map.show_tooltip "show_tooltip", :controller =>"users", :action => "show_tooltip"
  
  map.resource :account, :controller => "users"
  map.resource :user_session 
  map.resources :users, :has_many => [:positions, :educations, :connections]
  map.root :controller => "users", :action => "new"
end
