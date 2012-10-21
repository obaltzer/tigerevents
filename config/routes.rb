ActionController::Routing::Routes.draw do |map|
  # Add your own custom routes here.
  # The priority is based upon order of creation: first created -> highest priority.
  
  # Here's a sample route:
  # map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  map.connect 'events/list/week/:year/:month/:day', :controller => 'events', :action => 'list_week'
  map.connect 'events/list/:year/:month/:day', :controller => 'events', :action => 'list_day'
  map.connect 'events/list/:year/:month', :controller => 'events', :action => 'list_month'

  # You can have the root of your site routed by hooking up '' 
  # -- just remember to delete public/index.html.

  map.connect '', :controller => "events"
  map.events '', :controller => "events", :action => "index"

  # Allow downloading Web Service WSDL as a file with an extension
  # instead of a file named 'wsdl'
  map.connect ':controller/service.wsdl', :action => 'wsdl'

  map.connect ':controller', :action => 'list'
  
  # map.connect '/events/list/week/:year/:month/:day', :action => 'list_week'
  
  # Install the default route as the lowest priority.
  map.connect ':controller/:action/:id'


  # Malformed addresses will be redirected to the main page
  map.catchall "*anything", :controller => "events", :action => "index"
end
