require_dependency "login_system"
# The filters added to this controller will be run for all controllers in the application.
# Likewise will all the methods added be available for all controllers.
class ApplicationController < ActionController::Base
    include LoginSystem
    model :user
    helper :Application

    def can_edit
        if(@session[:user] == nil || @session[:user].banned == 1)
	    redirect_back_or_default :controller => "events", :action => "index"
	end
        if(@session[:user].superuser == 1)
	    return true
	end
	@event = Event.find(@params[:id])
	if(!@session[:user].approved_groups.include? Group.find(@event.group_id))
	    redirect_back_or_default :controller => "events", :action => "index"
	end
	true
    end

    def super_user
        if(!@session[:user])
            redirect_back_or_default :controller => "events", :action => "index"
	end
	if(@session[:user].superuser == 0)
            redirect_back_or_default :controller => "events", :action => "index"
	end
    end
end
