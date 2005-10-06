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
                _('You do not have permissions to edit this post.')
	    redirect_back_or_default :controller => "events", :action => "index"
	end
        if(@session[:user].superuser == 1)
	    return true
	end
	@event = Event.find(@params[:id])
	if(@event.deleted == 1)
            flash[:auth] = \
                _('You do not have permissions to edit this post.')
	    redirect_back_or_default :controller => "events", :action => "index"
	end
	if(!@session[:user].approved_groups.include? Group.find(@event.group_id))
            flash[:auth] = \
                _('You do not have permissions to edit this post.')
	    redirect_back_or_default :controller => "events", :action => "index"
	end
	true
    end

    def super_user
        if(!@session[:user])
            flash[:auth] = \
                _('You do not have permissions to access the page.')
            redirect_back_or_default :controller => "events", :action => "index"
	end
	if(@session[:user].superuser == 0)
            flash[:auth] = \
                _('You do not have permissions to access the page.')
            redirect_back_or_default :controller => "events", :action => "index"
	end
    end
end
