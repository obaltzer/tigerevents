class EventsController < ApplicationController
    before_filter :login_required, :only => [:new, :edit, 
                  :create, :update, :delete]
    before_filter :can_edit, :only => [:edit, :update, :delete]

    after_filter :store_location

    def index
        list
        render_action 'list'
    end

    def list
        # check if the request contained a predefined period
        set_view_period
        # retrieve the user customized layouts now if there are any
        if session[:user] and not session[:user].layouts.empty?
            @selectors = session[:user].layouts.selectors
        else
            # if there are none, use the NULL user
            @layout = Layout.find(:first, :conditions => "user_id IS NULL")
            @selectors = @layout.selectors
        end
    end

    # display the x latest active events posted
    def latest
        #default value of 10 events
        if not params[:id]
            params[:id] = 10
        end
        @events = Event.find(:all, 
          :limit => params[:id], 
          :include => [:group], 
          :order => "events.id DESC", 
          :conditions => ["events.startTime > ?", Time.now])
        #make sure that the number actually returned remains consistent
        #(due to lack of active events)
        params[:id] = @events.size
    end

    def show
        @event = Event.find(params[:id], :include => [:group])
        tags = @event.tag_names
        @categories = Category.category_objects(tags)
    end

    def new
        @event = Event.new
        @groups = Group.find(:all)
        @groupclasses = GroupClass.find(:all)
    end

    def edit
        @event = Event.find(params[:id])
        if @event.startTime < Time.now and (not @event.endTime or  @event.endTime < Time.now)
            redirect_to :action => 'list'
        end

        @categories = Category.find(:all)
        @groups = Group.find(:all)
        @groupclasses = GroupClass.find(:all)
    end

    def create
        @event = Event.new(params[:event])
        # assign the default priority to the event
        priority = Priority.find(:first, 
                        :conditions => ["name = ?", DEFAULT_PRIORITY])
        if priority
            @event.priority_id = priority.id
        else
            @event.priority_id = 1
        end
        @event.hasEndTime = params[:event_hasEndTime] ? true : false;
        if @event.group
            if not @event.group.authorized_users.include? session[:user]
                flash[:auth] = 
                    "You are not an authorized member of group " +
                    "'#{@event.group.name}'. Your posting will be displayed " +
                    "once your membership to '#{@event.group.name}' has " +
                    "been authorized by one its members."
            elsif @event.group.approved == false 
                flash[:auth] = 
                    "Group '#{@event.group.name}' is not approved yet. The " +
                    "#{ADMIN_CONTACT} is responsible for approving groups. " +
                    "Once your group is approved your postings for " +
                    "'#{@event.group.name}' will be displayed. If you have " +
                    "any questions please contact the #{ADMIN_CONTACT} at " +
                    "#{ADMIN_EMAIL}."    
            end
        end
        if @event.save
            # only associate user with group after the event has been
            # created to ensure the group exists
            @event.group.users.push_with_attributes(session[:user], 
                'authorized' => false ) \
                    unless @event.group.users.include? session[:user]
            @event.tag(params[:tags], :separator => ',', :attributes =>\
                {:created_by => session[:user]})
            
            log_activity(@event, session[:user], 'CREATE')
            flash[:notice] = 'Event was successfully created.'
            # clear selectors cache
            SelectorsController.clearCache
           
            redirect_to :action => 'list'
        else
            @categories = Category.find(:all)
            @groups = Group.find(:all)
            @groupclasses = GroupClass.find(:all)
            render_action 'new'
        end
    end
     
    def update
        @event = Event.find(params[:id])
        if @event.startTime < Time.now and (not @event.endTime or  @event.endTime < Time.now)
            redirect_to :action => 'list'
        end

        # make sure only superusers can set the priority if someone
        # hand-crafts a URL
        if params[:event][:priority_id] and !session[:user][:superuser]
            flash[:notice] = 'You do not have permissions to set the event priority.'
            render_action 'edit'
            return true
        end
        
        # make sure to set endTime == nil when the box is unchecked  
        @event.hasEndTime = params[:event_hasEndTime] ? true : false;
         
        if @event.update_attributes(params[:event])
            
            # The following is only necessary, if the user who edited the
            # event, has changed the group of the event to a group of which
            # the user is not a member yet. Hence, associate the user with
            # the group as an unautorized member, if the user-group
            # association does not exist yet.
            @event.group.users.push_with_attributes( session[:user], 'authorized' => false ) \
                unless @event.group.users.include? session[:user] \
                        or session[:user][:superuser]
            @event.tag(params[:tags], :separator => ',', :clear => true,\
                :attributes => {:created_by => session[:user]})
            log_activity(@event, session[:user], 'MODIFY')
            flash[:notice] = 'Event was successfully updated.'
            # clear selectors cache
            SelectorsController.clearCache
            redirect_to :back
        else
            render_action 'edit'
        end
    end

    def get_event
        if params[:id]
            @event = Event.find(params[:id])
        else
            @event = Event.new(params[:event])
        end
    end

    def list_categories
        get_event
        @categories = Category.find(:all).sort_by { |a| a.name }
        render_partial
    end
    
    def list_groups
        get_event
        @groups = Group.find( :all, :order => "name ASC" )
        render_partial
    end    

    def delete
        #Event.update(params[:id], :deleted => 1)
        event = Event.find(params[:id])
        #can't delete events that have already past
        if event.startTime < Time.now and (not event.endTime or  event.endTime < Time.now)
            flash[:notice] = "Can't delete events that have already past"
            redirect_to :action => 'list'
        end

        event.update_attribute( :deleted, true )
        # clear selectors cache
        SelectorsController.clearCache
        redirect_to :controller => 'groups', :action => 'list_events_remote', :id => params[:group_id]
    end

    def set_view_period
        # see if user has specified custom time period
        if params[:period] \
          and params[:period][:start_date] \
          and params[:period][:end_date]
            # preserve form values in period variable
            p = params[:period]
            now = Time.now
            
            # try creating a time object for the start date
            begin
                start_date = params[:period][:start_date].split(/\//)
                p[:startTime] = Time.local start_date[2], start_date[1], \
                    start_date[0], now.hour, now.min, 0, 0
            rescue
              flash[:notice] ="Invalid start date for time period selection."
              error = true
            end
            
            begin
                end_date = params[:period][:end_date].split(/\//)
                p[:endTime] = Time.local end_date[2], end_date[1], \
                    end_date[0], now.hour, now.min, 0, 0
            rescue 
                flash[:notice] = \
                    "Invalid end date for time period selection."
                error = true
            end
            params[:period].delete :fixed
            params[:period][:custom] = true
        end
        
        # user did not specify custom time period or it failed to
        # initialize
        if not params[:period] or not (p[:startTime] and p[:endTime])
            p = {}
            p[:fixed] = params[:id] ||= "this_month"
            # the default display is this week
            if params[:id] == "next_week"
                p[:startTime] = week_start = 7.days.from_now - (7.days.from_now.wday).days
                p[:endTime] = week_start + 7.days
            elsif params[:id] == "next_month"
                p[:startTime] = month_start = 1.month.from_now - (1.month.from_now.day - 1).days
                p[:endTime] = month_start + 1.month
            elsif params[:id] == "this_month"
                p[:startTime] = Time.now
                p[:endTime] = 1.month.from_now 
            elsif params[:id] == "this_week"
                p[:startTime] = Time.now
                p[:endTime] = 7.days.from_now
            else
                # default is the this_week
                p[:fixed] = "this_month"
                p[:startTime] = Time.now
                p[:endTime] = 7.days.from_now
            end
        end
        @period = params[:period] = p
    end
    private :set_view_period
end
