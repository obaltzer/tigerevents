# The methods added to this helper will be available to all templates in the application.
module ApplicationHelper
    def self.append_features(controller)
        controller.ancestors.include?(ActionController::Base) ?
        controller.add_template_helper(self) : super
    end
    
    def submit_remote(name, value, form_id, options = {})
        # since render_component passes the parameter list as a
        # HashWithIndifferentAccess, we have to make sure that options is
        # always a hash with indifferent access
        options = options.with_indifferent_access 
        
        options[:with] = "Form.serialize(#{form_id})"
        options[:html] ||= {}
        options[:html][:type] = 'button'
        options[:html][:onclick] ||= ''
         
        if options[:html][:onsubmit]
            options[:html][:onclick] << options[:html][:onsubmit]
            options[:html].delete("onsubmit")
        end
        
        options[:html][:onclick] << ";#{remote_function(options)}; return false;"
        options[:html][:name] = name
        options[:html][:value] = value
        options[:html][:id] = name
        
        output = ""
        if options[:update_with]
            output << tag("input", { :type => "hidden", :name => "update_with", \
                        :value => url_for(options[:update_with]) }, false)
        end
        if options[:update]
            output << tag("input", { :type => "hidden", :name => "update", \
                        :value => url_for(options[:update]) }, false)
        end
        output << tag("input", options[:html], false)
        output
    end

    def select_hour(name, attribute)
        value = eval("@#{name}.#{attribute}")
        hour_options = []
        1.upto(12) do |hour|
            hour_options << ( hour == value ?
                %(<option value="#{leading_zero_on_single_digits(hour)}" selected="selected">#{leading_zero_on_single_digits(hour)}</option>\n) :
                %(<option value="#{leading_zero_on_single_digits(hour)}">#{leading_zero_on_single_digits(hour)}</option>\n)
            )
        end
        %(<select name="#{name}[#{attribute}]" id="#{name}_#{attribute}">\n)\
            + hour_options.to_s \
            + %(</select>)
    end

    def select_min(name, attribute)
        value = eval("@#{name}.#{attribute}")
        min_options = []
        0.step(55, 5) do |min|
            min_options << ( min == value ?
                %(<option value="#{leading_zero_on_single_digits(min)}" selected="selected">#{leading_zero_on_single_digits(min)}</option>\n) :
                %(<option value="#{leading_zero_on_single_digits(min)}">#{leading_zero_on_single_digits(min)}</option>\n)
            )
        end
        %(<select name="#{name}[#{attribute}]" id="#{name}_#{attribute}">\n)\
            + min_options.to_s \
            + %(</select>)
    end

    def select_ampm(name, attribute)
        value = eval("@#{name}.#{attribute}")
        %(<select name="#{name}[#{attribute}]" id="#{name}_#{attribute}">\n)\
            + %(<option value="0") + (value ? "" : %(selected="selected")) + %(>am</option>\n)\
            + %(<option value="1") + (value ? %(selected="selected") : "") + %(>pm</option>\n)\
            + %(</select>)
    end

    def context_help(action = nil)
        @context = {}
        @context[:controller] = params[:controller]
        @context[:action] = "help"
        @context[:id] = action ? action : params[:action]
        render :partial => 'layouts/context_help'
    end

    def default_stylesheets
        render :partial => 'layouts/default_stylesheets'
    end

    def default_javascripts
        render :partial => 'layouts/default_javascripts'
    end

    # User actions are generated from the following lists depending on the
    # permissions of the user.
    @@user_actions = [
        { :perm => [:superuser], :name => 'Groups', :action => { :controller => 'groups', :action => 'list'}, :attr => {:important => "new_group_notice?" }},
        { :perm => [:superuser], :name => 'Group Classes', :action => { :controller => 'group_classes', :action => 'list' } },
        { :perm => [:superuser], :name => 'Priorities', :action => { :controller => 'priorities'} },
        { :perm => [:superuser], :name => 'Users', :action => { :controller => 'account', :action => 'list'} },
        { :perm => [:superuser], :name => 'Edit Layout', :action => { :controller => 'layouts', :action => 'edit', :id => 1} },
        { :perm => [:superuser], :name => 'Categories', :action => { :controller => 'categories', :action => 'edit'} },
        { :perm => [], :name => 'Logout', :action => { :controller => 'account', :action => 'logout' } },
    ]

    def list_user_actions
      perm = session[:user].superuser? ? :superuser : :default
      actions = []
      @@user_actions.each { |a|
        # add the action to the actions list if either no permissions are
        # assigned or the permissions list is empty or the permissions of
        # the user are included in the permissions list
        if not a[:perm] or a[:perm].length == 0 or a[:perm].include? perm
          x = {}.update(a)
          # if there are extra attributes that need to be generated do so 
          if a[:attr]
            a[:attr].keys.each { |k|
              x[k] = eval(a[:attr][k])
            }
          end
          actions << x
        end
      }
      return actions
    end
    
    def tag_cloud(tag_cloud, category_list)
        max, min = 0, 0
        tag_cloud.each_value do |count|
            max = count if count > max
            min = count if count < min
        end

        divisor = ((max - min) / category_list.size) + 1

        tag_cloud.each do |tag, count|
            yield tag, category_list[(count - min) / divisor] 
        end
    end

    def to_formatted_s(format = :default)
        DATE_FORMATS[format] ? strftime(DATE_FORMATS[format]).strip : to_default_s          
    end

    def print_hcard_time(startTime, endTime, format)
        if(MILITARY_TIME_FORMAT)
            format = (format.to_s+"_24h").to_sym
        end
        time = "<abbr class=\"dtstart\"
        title=\"#{startTime.strftime("%Y-%m-%dT%H:%M:%S-04:00")}\">#{startTime.to_ordinalized_s(format)}</abbr>"
        if(endTime!=nil)
            time+= " - <abbr class=\"dtend\" \
            title=\"#{endTime.strftime("%Y-%m-%dT:%H:%M:%S-04:00")}\">" \
              + endTime.to_ordinalized_s(((endTime - startTime) < 1.day)? :hour_format : format) \
              + "</abbr>"
        end
        return time
    end

    def print_time(startTime, endTime, format)
        if(MILITARY_TIME_FORMAT)
            format = (format.to_s+"_24h").to_sym
        end
        time = startTime.to_ordinalized_s(format)
        if(endTime!=nil)
            time+= " - " + endTime.to_ordinalized_s(
              ((endTime - startTime) < 1.day)? :hour_format : format)
        end
        return time
    end

    def new_group_notice?
      unapproved = Group.find(:first, 
                :conditions => ["approved = ? AND deleted = ?", false, false],
                :order => "name ASC")
      return true if unapproved != nil
    end

end
