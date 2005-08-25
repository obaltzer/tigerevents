class GroupsController < ApplicationController
    before_filter :login_required, :only => [:create_remote, :edit, \
                  :unauthorized_remote, :authorize_members, :authorized_remote, \
                  :remove_member, :list_events_remote]
    before_filter :belongs_to, :only => [:edit, :unauthorized_remote, \
                  :authorize_members, :authorized_remote, :remove_member, \
                  :list_events_remote, :update]
    before_filter :super_user, :only => [:list]

    def create_remote
        @group = Group.new(@params[:group])
        if @group.save && @group.users.push_with_attributes( @session[:user], :authorized => 1 )
            # redirect back to the group listing for the current event
            redirect_to @params[:update_with]
        else
            render_partial 'embed_error_message'
        end
    end

    def update
        @group = Group.find(@params[:id])
        if @session[:user].superuser != 1
            @params[:group][:approved] = 0
        end
        if @group.update_attributes(@params[:group])
            flash[:notice] = 'Group properties successfully updated.'
            SelectorsController.clearCache
            # generate a new request such that the authentication based
            # redirection kicks in
            redirect_to :action => 'edit', :id => @group
        else
            @group_classes = GroupClass.find_all
            render_action 'edit'
        end
    end

    def approve
	@group = Group.find(@params[:id])
	@group.approved = 1
	@group.save
        # clear cache to render events of the approved group
        SelectorsController.clearCache
	redirect_to :action => "list"
    end
    
    def ban
	@group = Group.find(@params[:id])
	@group.approved = 0
	@group.save
        # clear cache to hide eventsof the banned group
        SelectorsController.clearCache
	redirect_to :action => "list"
    end
    
    def new_remote
        @group = Group.new
        @group_classes = GroupClass.find_all
        render_partial
    end
    
    def show
        @group = Group.find(@params[:id])
    end

    def mygroups
    	@groups = @session[:user].approved_groups
    	@pengroups = @session[:user].unapproved_groups
    	@penmember = @session[:user].unapproved_member
	render_partial
    end

    def list
        @newgroups = Group.find(:all, :conditions => "approved = 0")
        @groups = Group.find(:all, :conditions => "approved = 1")
    end

    #checks to see if the user belongs to this group
    def belongs_to
        if(@session[:user] == nil || @session[:user].banned == 1)
	    redirect_to :controller => "events", :action => "index"
        end
        if(@session[:user].superuser == 1)
	    return true
	end
	if(!@session[:user].approved_groups.include? Group.find(@params[:id]))
	    redirect_to :controller => "events", :action => "index"
        end
	true
    end
							
    def edit
       @group = Group.find(@params[:id])
       @group_classes = GroupClass.find_all
    end

    #the next two methods deal with finding unauthorized members and possibly authorizing or dismissing them
    def unauthorized_remote
        @group = Group.find(@params[:id])
        @unauthorized_members = @group.unauthorized_users
        render_partial
    end

    #authorizes and dismisses users requesting membership to the group
    def authorize_members
        @group = Group.find(@params[:id])
        if @params[:member]
          for m in @params[:member].keys
             user = User.find(m)
             #approve the user if the authorized radio button has been selected
             if @params[:member][m][:authorized] == '1'
                @group.users.delete( user )
                @group.users.push_with_attributes( user, 'authorized' => 1 )

             #otherwise, flagged their submitted events for this group as deleted
             else
                #get the events the user created for the group
                events_to_delete = Event.find(:all, \
                                    :include => [:creators], \
                                    :conditions => ['group_id = ? AND user_id = ?', @group.id, m])
                #flagged them as deleted
                for e in events_to_delete
                   e.update_attribute( :deleted, 1 );
                end
                @group.users.delete( user )
             end
          end
          # clear selectors cache
          SelectorsController.clearCache
        end
        render_partial 'members_section', :id => @params[:id] 
    end

    #the next two methods deal with finding authorized members and possibly removing them
    def authorized_remote
        @group = Group.find(@params[:id])
        @authorized_members = @group.authorized_users
        @complement_authorized_members = {}
        for m in @authorized_members do
            @complement_authorized_members[m] = Array.new(@authorized_members)
            @complement_authorized_members[m].delete_if { |x| x.id == m.id }
        end
        render_partial
    end

    #removes the member from the group
    def remove_member
        group = Group.find @params[:id]
        user = User.find @params[:user_id]
        adopter = User.find @params[:adopter_id]
        # find the events that belong to the user
        events = Event.find :all,\
            :joins => "LEFT JOIN groups ON events.group_id = groups.id "\
                    + "LEFT JOIN groups_users ON "\
                        + "groups_users.group_id = groups.id "\
                    + "LEFT JOIN users ON users.id = groups_users.user_id "\
                    + "LEFT JOIN activities ON "\
                        + "users.id = activities.user_id AND "\
                        + "events.id = activities.event_id",\
            :conditions => ["action IN ('CREATE', 'ADOPT') AND "\
                            + "groups.id = ? AND users.id = ?", \
                            group.id, user.id]
        # adopt events from user_id to adopter_id 
        for e in events do
            a = Activity.new
            a.event = e
            a.user = adopter
            a.action = 'ADOPT'
            a.save
        end
        group.users.delete user
        # clear selectors cache
        SelectorsController.clearCache
        redirect_to :action => "authorized_remote", :id => @params[:id]
    end

    #these methods are for editing events that belong to the group
    def list_events_remote
       @group = Group.find(@params[:id])
       @events = @group.undeleted_events
       render_partial
    end
    
    #shows all events, lets you edit only those that haven't passed.
    def history
	@group = Group.find(@params[:id])
	@events = @group.undeleted_events
    end
end
