require_dependency "login_system"
# The filters added to this controller will be run for all controllers in the application.
# Likewise will all the methods added be available for all controllers.
class ApplicationController < ActionController::Base
    include LoginSystem
    model :user
    helper :Application
    theme :get_theme
    layout :get_layout

    def get_theme
        # returning the theme that is associated with the session
        if session[:theme]
            # the code will make sure, that the session theme is replaced
            # with the user theme on authentication to avoid testing for
            # valid theme for every page
            return session[:theme]
        end
        return DEFAULT_THEME
    end

    def get_layout
        return 'default'
    end

    def log_activity(event, user, action)
        @activity = Activity.new(:event => event, :user => user, :action => action)
        @activity.save
    end

    def no_permission
      flash[:auth] = 'You do not have permissions to access the page.'
      redirect_back_or_default :controller => "events", :action => "index"
    end

    def can_edit
        if(session[:user] == nil || session[:user].banned)
          no_permission
        elsif(session[:user][:superuser])
            return true
        end
        @event = Event.find(params[:id])
        if(@event.deleted)
          no_permission
        elsif(!session[:user].approved_groups.include? Group.find(@event.group_id))
          no_permission
        end
        true
    end

    def super_user
      if(session[:user] == nil || !session[:user][:superuser])
        no_permission
      end
    end

    def help
        render :partial => params[:controller] + "/help_" + params[:id]
    end

    # store current uri in  the session.
    # we can return to this location by calling return_location
    def store_location
        session[:return_to] = @request.request_uri
    end

    # move to the last store_location call or to the passed default one
    def redirect_back_or_default(default)
        if session[:return_to].nil?
            redirect_to default
        else
            redirect_to_url session[:return_to]
            session[:return_to] = nil
        end
    end

    def create_ical_event(event)
      calevent = Icalendar::Event.new
      calevent.start = event.startTime.strftime("%Y%m%dT%H%M%SZ")
      calevent.end = event.endTime.strftime("%Y%m%dT%H%M%SZ") if event.endTime
      calevent.summary = event.title
      calevent.description = event.description if event.description
      calevent.organizer = event.group.name 
      calevent.location = event.location if event.location
      return calevent
    end

end
