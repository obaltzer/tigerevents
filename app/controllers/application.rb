require_dependency "login_system"
# The filters added to this controller will be run for all controllers in the application.
# Likewise will all the methods added be available for all controllers.
class ApplicationController < ActionController::Base
    include LoginSystem
    model :user
    helper :Application

    def can_edit
        if(@session[:user] == nil || @session[:user].banned == 1)
            flash[:auth] = \
                "You do not have permissions to edit this posting."
	    redirect_back_or_default :controller => "events", :action => "index"
        elsif(@session[:user][:superuser])
	    return true
	end
	@event = Event.find(@params[:id])
	if(@event.deleted == 1)
            flash[:auth] = \
                "You do not have permissions to edit this posting."
	    redirect_back_or_default :controller => "events", :action => "index"
	elsif(!@session[:user].approved_groups.include? Group.find(@event.group_id))
            flash[:auth] = \
                "You do not have permissions to edit this posting."
	    redirect_back_or_default :controller => "events", :action => "index"
	end
	true
    end

    def super_user
        if(@session[:user] == nil || !@session[:user][:superuser])
            flash[:auth] = \
                'You do not have permissions to access the page.'
            redirect_back_or_default :controller => "events", :action => "index"
	end
    end
end
