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
end
