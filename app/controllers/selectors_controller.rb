require 'active_support/inflector'

class SelectorsController < ApplicationController
    @@cache = {}
   
    def index
        list
        render_action 'list'
    end
    
    def list
        @selectors = Selector.find_all
    end
    
    def list_events
        #if the cacheKey is nil then it should not be stored
        cacheKey = nil 
        if @params[:period] 
           cacheKey = "#{@params[:id]}_#{@params[:period]}" 
        end

        #do not perform selection if it is in the cache
        #or it is a selection for a manually specified time period
        unless cacheKey and @@cache.has_key? cacheKey \
               and @@cache[cacheKey][:expires] > Time.now
              
            # get the selector with the given ID
            selector = \
                Selector.find(@params[:id])
           
            # computing the conditions depending on the associations
            # between the selector and other entities
            association_types = AssociationType.find_all
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
            if selector.include_announcements != selector.include_events
                type_cond = " AND events.announcement = " \
                    + (selector.include_announcements == 1 ? "1" : "0")\
                    + " "
            end
            #initialize the start and end time to be used for the time_cond. These may or may not be
            #initialized with arguments in @params
            #default time period is 7 days
            startTime = Date.today.to_time
            endTime = 7.days.from_now.at_beginning_of_day
 
            #check params
            if @params[:startTime] && @params[:endTime]
               startTime = Time.local @params[:startTime][:year], @params[:startTime][:month], @params[:startTime][:day]
               #add more day to endTime to be inclusive of the last day
               endTime = Time.local( @params[:endTime][:year], @params[:endTime][:month], @params[:endTime][:day] ).tomorrow
            end

            time_cond = ""
                # get all announcements which have started and not ended
                # yet
            time_cond << " AND ((events.announcement = 1 "\
                            + "AND startTime <= '#{startTime.to_formatted_s(:db) }' "\
                            + "AND endTime > '#{startTime.to_formatted_s(:db) }' ) OR "
                # get all events that... 
            time_cond << "(events.announcement = 0 "
                # start before the end of the time period
            time_cond << "AND startTime <= '#{endTime.to_formatted_s(:db) }' "
                    # and have not started yet
            time_cond << "AND ( startTime >= '#{startTime.to_formatted_s(:db) }' "
                    # ... or have endTime, but end time has not been
                    # reached yet 
            time_cond << "OR (endTime IS NOT NULL AND endTime > '#{startTime.to_formatted_s(:db) }') )))"
            # find the approved events association with the selector
            events = Event.find(\
                :all, \
                :include => [:categories, :group, :priority], \
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
                    + "groups.approved = 1 "\
                    + "AND groups_users.authorized = 1 "\
                    + "AND activities.user_id IS NOT NULL "\
                    + "AND deleted = 0 "\
                    + "AND users.banned = 0 "\
                    + type_cond + time_cond] + condition_val,\
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
end
