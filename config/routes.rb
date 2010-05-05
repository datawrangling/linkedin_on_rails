ActionController::Routing::Routes.draw do |map|
  map.login "login", :controller => "user_sessions", :action => "new"
  map.logout "logout", :controller => "user_sessions", :action => "destroy"
  
  map.resource :account, :controller => "users"
  map.resource :user_session 
  map.resources :users, :has_many => [:positions, :educations, :connections]
  map.root :controller => "users", :action => "new"
end
