class SetupController < ApplicationController
   before_filter :login_required

   def index
      unless (session[:user].login == SUPER_USER)
         flash[:notice] = 'You have to be the TigerEvents Super User to access the Setup page'
         redirect_to( :controller => "account", :action => "login" )
      end
      @users = User.find_all
      @groups = Group.find_all
      @group_classes = GroupClass.find_all
   end
end
