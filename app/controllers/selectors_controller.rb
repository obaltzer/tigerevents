require 'active_support/inflector'

class SelectorsController < ApplicationController
    before_filter :login_required, 
                  :only => [:edit, :create, :associate, :update]
    before_filter :super_user, 
                  :only => [:edit, :create, :associate, :update]

    @@cache = {}
   
    def index
        list
        render_action 'list'
    end
    
    def list
        @selectors = Selector.find(:all)
    end
    
    def events
        #if the cacheKey is nil then it should not be stored
        cacheKey = nil
        if params[:period] and params[:period][:fixed] \
                and not params[:search]
            cacheKey = "#{params[:id]}_#{params[:period][:fixed]}" 
        end

        #do not perform selection if it is in the cache
        #or it is a selection for a manually specified time period
        unless cacheKey and @@cache.has_key? cacheKey \
               and @@cache[cacheKey][:expires] > Time.now
              
            # get the selector with the given ID
            selector = \
                Selector.find(params[:id])
           
            # computing the conditions depending on the associations
            # between the selector and other entities
            association_types = AssociationType.find(:all)
            condition_str = []
            condition_val = []
            for t in association_types do
                condition_str_parts = []
                for e in selector.associations do
                    tmp = []
                    selector.send(Inflector.pluralize(e)).each { |x|
                        tmp << x.id if x.association_type_id.to_i == t.id
                    }
                    unless tmp.empty?
                        condition_str_parts << Inflector.pluralize(e)\
                            + ".id IN (?)"
                        condition_val << tmp
                    end
                end
                condition_str << "("\
                    + condition_str_parts.join(" " + t.name + " ") + ")"\
                    unless condition_str_parts.empty?
            end
            if condition_str.empty?
                conditions = ""
            else
                conditions = condition_str.join(" OR ") + " AND "
            end
           
            # assemble the conditions to select announcements or events
            # respectively
            type_cond = ""
            type_val = []
            if selector.include_announcements != selector.include_events
                type_cond = " AND events.announcement = ?" 
                type_val << (selector.include_announcements == true ? true : false)
            end

            #check params
            if params[:period] and params[:period][:startTime] \
                    and params[:period][:endTime]
                startTime = params[:period][:startTime]
                #Time.local params[:startTime][:year], params[:startTime][:month], params[:startTime][:day]
                #add more day to endTime to be inclusive of the last day
                endTime = params[:period][:endTime]
                #Time.local( params[:endTime][:year], params[:endTime][:month], params[:endTime][:day] ).tomorrow
            else
                #initialize the start and end time to be used for the time_cond. These may or may not be
                #initialized with arguments in params
                #default time period is 7 days
                startTime = Time.now
                endTime = 7.days.from_now.at_beginning_of_day
            end
    
            if params[:search] and not params[:search] == ""
                tokens = params[:search].split.collect {
                    |c|
                    "%#{c.downcase}%"
                }
                search_cond = " AND " + 
                    (["(LOWER(events.title) LIKE ? " +
                        "OR LOWER(events.description) LIKE ? " +
                        "OR LOWER(groups.name) LIKE ? " +
                        "OR LOWER(groups.description) LIKE ?)"] *
                        tokens.size).join(" AND ")
                search_val = *tokens.collect { |t| [t] * 4 }.flatten
            else
                search_cond = ""
                search_val = []
            end
            
            time_cond = ""
            time_val = []
                # get all announcements which have started and not ended
                # yet
            time_cond << " AND ((events.announcement = ? "\
                            + "AND startTime <= '#{startTime.to_formatted_s(:db) }' "\
                            + "AND endTime > '#{startTime.to_formatted_s(:db) }' ) OR "
            time_val << true
                # get all events that... 
            time_cond << "(events.announcement = ? "
            time_val << false
                # start before the end of the time period
            time_cond << "AND startTime <= '#{endTime.to_formatted_s(:db) }' "
                    # and have not started yet
            time_cond << "AND ( startTime >= '#{startTime.to_formatted_s(:db) }' "
                    # ... or have endTime, but end time has not been
                    # reached yet 
            time_cond << "OR (endTime IS NOT NULL AND endTime > '#{startTime.to_formatted_s(:db) }') )))"
            # find the approved events association with the selector

            show_cond = ""
            show_val = []
            show_cond << "groups.approved = ?"
            show_val << true
            show_cond << " AND groups_users.authorized = ?"
            show_val << true
            show_cond << " AND events.deleted = ?"
            show_val << false
            show_cond << " AND groups.deleted = ?"
            show_val << false
            show_cond << " AND users.banned = ?"
            show_val << false

            events = Event.find(\
                :all, \
                :include => [:group, :priority], \
                :joins => "LEFT JOIN group_classes ON "\
                    + "groups.group_class_id = group_classes.id "\
                    + "LEFT JOIN groups_users ON "\
                    + "groups.id = groups_users.group_id "\
                    + "LEFT JOIN activities ON "\
                    + "activities.event_id = events.id "\
                    + "AND activities.action IN ('CREATE', 'ADOPT') "\
                    + "AND activities.user_id = groups_users.user_id "\
                    + "LEFT JOIN users ON "\
                    + "users.id = activities.user_id", \
                :conditions => [conditions \
                    + show_cond \
                    + type_cond + time_cond + search_cond] + condition_val + show_val + type_val +
                        time_val + search_val, \
                :order => "events.startTime, priorities.rank, "\
                        + "activities.created_on DESC")
            #cache the query if it is from a defined period
            if cacheKey
                @@cache[cacheKey] = \
                   { :selector => selector, :events => events, \
                   :expires => Time.now + EXPIRY_TIME }
            end
            #grab selector and events
            @selector = selector
            @events = events 
        else    #it is cached
           @selector = @@cache[cacheKey][:selector]
           @events = @@cache[cacheKey][:events]
        end

        render_partial
    end

    def SelectorsController.clearCache
        @@cache.clear
    end

    def edit
        @selector = Selector.find(params[:id])
        @associations = {}
        @selector.associations.each do |a|
            @associations[a] = {}
            @associations[a][:active] = @selector.send(Inflector.pluralize(a))
            tmp = Array.new(eval(Inflector.camelize(a)).find(:all))
            tmp.reject! { |x|
                @associations[a][:active].include?(x) 
            }
            @associations[a][:available] = tmp
        end
        render :partial => "edit"
    end

    def associate
        @selector = Selector.find params[:id]
        association = params[:association]
        list = params["list_active_#{association}"] || []
        assoc = Inflector.pluralize(association)
        # we have updated the list for association a, now store the
        # new association, but delete all old ones first
        @selector.send(assoc).clear
        # get all possible association objects for this association
        map = {}
        eval(Inflector.camelize(association)).find(:all).each do |x| 
            map[x.id] = x
        end
        # now iterate over the new associations and add them to the
        # associations table as OR relationship
        list.each do |x|
            @selector.send(assoc).push_with_attributes(
                map[x.to_i], "association_type_id" => 1)
        end
        SelectorsController.clearCache
        render_partial
    end

    def create
        @selector = Selector.new(params[:selector])
        @selector.label = @selector.name.to_s.gsub(/::/, '/').gsub(/ /,'_').downcase
        @selector.include_announcements = true
        @selector.include_events = true
        if @selector.save
            params[:id] = @selector.id
            edit
        else
            render_partial "error_message"
        end
    end

    def update
        @selector = Selector.find(params[:id])
        if @selector.name != params[:selector][:name]
            params[:selector][:label] = 
                params[:selector][:name].to_s.gsub(/::/, '/').gsub(/ /,'_').downcase
        end
        if @selector.update_attributes(params[:selector])
            SelectorsController.clearCache
            render_partial "properties_updated"
        else
            render_partial "error_message"
        end
    end
    
    def properties
        @selector = Selector.find(params[:id])
        render_partial "selector_properties"
    end

    def delete
        selector = Selector.find(params[:id])
        if selector
            for e in selector.associations do
                selector.send(Inflector.pluralize(e)).clear
            end
            selector.destroy
        end
        render_partial
    end
end
