class EventsController < ApplicationController

    before_filter :login_required, :only => [:new, :edit, 
                  :create, :update, :delete]
    before_filter :can_edit, :only => [:edit, :update,  
                  :delete]
 
    def index
        list
        render_action 'list'
    end

    def list
        # check if the request contained a predefined period
        set_view_period
        # retrieve the user customized layouts now if there are any
        if @session[:user] and not @session[:user].layouts.empty?
            @selectors = @session[:user].layouts.collect { |x| x.selector }
        else
            # if there are none, use the NULL user
            @selectors= Layout.find(:all,\
                :conditions => "user_id IS NULL",\
                :order => "rank").collect { |x| x.selector_id }
        end
    end

    def show
        @event = Event.find(@params[:id])
    end

    def new
        @event = Event.new
        @groups = Group.find_all
        @groupclasses = GroupClass.find_all
    end

    def create
        @event = Event.new(@params[:event])
	@event.priority_id = \
            Priority.find(:first, :conditions => "name = 'Normal'").id
        @event.hasEndTime = @params[:event_hasEndTime] ? true : false;
        if @event.group
	   if not @event.group.authorized_users.include? @session[:user]
	      flash[:auth] = "You are not an authorized member of the #{@event.group.name}. " +
                          "Your posting will be displayed once your membership to #{@event.group.name} " +
                          "has been authorized by one its members."
           elsif @event.group.approved == 0
              flash[:auth] = "Group #{@event.group.name} is not approved yet. The #{ADMIN_CONTACT} is responsible " +
                          "for approving groups. Once your group is approved your postings for #{@event.group.name} " + 
                          "will be displayed. If you have any questions please contact the #{ADMIN_CONTACT} at #{ADMIN_EMAIL}."    
	   end
        end
	if @event.save
            # only associate user with group after the event has been
            # created to ensure the group exists
            @event.group.users.push_with_attributes( @session[:user], 'authorized' => 0 ) \
                unless @event.group.users.include? @session[:user]
            
            log_activity @event, 'CREATE'
            flash[:notice] = 'Event was successfully created.'
            # clear selectors cache
            SelectorsController.clearCache
           
            redirect_to :action => 'list'
        else
            @categories = Category.find_all
            @groups = Group.find_all
            @groupclasses = GroupClass.find_all
            render_action 'new'
        end
    end
     
    def edit
        @event = Event.find(@params[:id])
        if @event.startTime < Time.now and (not @event.endTime or  @event.endTime < Time.now)
           redirect_to :action => 'list'
        end

        @categories = Category.find_all
        @groups = Group.find_all
        @groupclasses = GroupClass.find_all
    end

    def update
        @event = Event.find(@params[:id])
        if @event.startTime < Time.now and (not @event.endTime or  @event.endTime < Time.now)
           redirect_to :action => 'list'
        end

        # make sure only superusers can set the priority if someone
        # hand-crafts a URL
        if @params[:event][:priority_id] and @session[:user].superuser != 1
            flash[:notice] = 'You do not have permissions to set '\
                             + 'the event priority.'
            render_action 'edit'
            return true
        end
            
        # make sure to set endTime == nil when the box is unchecked  
        @event.hasEndTime = @params[:event_hasEndTime] ? true : false;
         
        if @event.update_attributes(@params[:event])
            
            # associate user with new group, if the association does not
            # exist yet
            @event.group.users.push_with_attributes( @session[:user], 'authorized' => 0 ) \
                unless @event.group.users.include? @session[:user]

            log_activity @event, 'MODIFY'
            flash[:notice] = 'Event was successfully updated.'
            # clear selectors cache
            SelectorsController.clearCache
            redirect_to :action => 'show_remote', :id => @event
        else
            render_action 'edit'
        end
    end

    def list_categories
        if @params[:id]
            @event = Event.find(@params[:id])
        else
            @event = Event.new(@params[:event])
        end
        @categories = Category.find_all
        render_partial
    end
    
    def list_groups
        if @params[:id]
            @event = Event.find(@params[:id])
        else
            @event = Event.new(@params[:event])
        end
        @groups = Group.find_all
        render_partial
    end    

    def log_activity(event, action)
        @activity = Activity.new
        @activity.event = event
        @activity.user = @session[:user]
        @activity.action = action
        @activity.save
    end

    def delete
        #Event.update(@params[:id], :deleted => 1)
        event = Event.find(@params[:id])
        if @event.startTime < Time.now and (not @event.endTime or  @event.endTime < Time.now)
           redirect_to :action => 'list'
        end

        event.update_attribute( :deleted, 1 )
        redirect_to :controller => 'groups', :action => 'list_events_remote', :id => @params[:group_id]
    end

    def set_view_period
        # see if user has specified custom time period
        if @params[:period] and @params[:period][:start_date] \
                and @params[:period][:end_date]
            p = @params[:period]
            now = Time.now
            begin
                start_date = @params[:period][:start_date].split(/\//)
                p[:startTime] = Time.local start_date[2], start_date[1], \
                    start_date[0], now.hour, now.min, 0, 0
            rescue
                flash[:notice] = \
                    "Invalid start date for time period selection."
            end
            begin
                end_date = @params[:period][:end_date].split(/\//)
                p[:endTime] = Time.local end_date[2], end_date[1], \
                    end_date[0], now.hour, now.min, 0, 0
            rescue 
                flash[:notice] = \
                    "Invalid end date for time period selection."
            end
            @params[:period].delete :fixed
            @params[:period][:custom] = true
        else # user did not specify custom time period
            p = {}
            p[:fixed] = @params[:id] ||= "this_week"
            # the default display is this week
            if @params[:id] == "next_week"
                p[:startTime] = week_start = 7.days.from_now - (7.days.from_now.wday).days
                p[:endTime] = week_start + 7.days
            elsif @params[:id] == "next_month"
                p[:startTime] = month_start = 1.month.from_now - (1.month.from_now.day - 1).days
                p[:endTime] = month_start + 1.month
            elsif @params[:id] == "this_month"
                p[:startTime] = Time.now
                p[:endTime] = 1.month.from_now 
            else
                # default is the this_week
                p[:fixed] = "this_week"
                p[:startTime] = Time.now
                p[:endTime] = 7.days.from_now
            end
        end
        @period = @params[:period] = p
    end
    private :log_activity, :set_view_period
end
