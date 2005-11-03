require './config/boot'
require './config/environment.rb'
fork do
    exec "rake migrate"
end
Process.wait
    
User.destroy_all
Priority.destroy_all
Layout.destroy_all
Selector.destroy_all
AssociationType.destroy_all
