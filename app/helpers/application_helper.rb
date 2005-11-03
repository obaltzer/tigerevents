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
        @context[:controller] = @params[:controller]
        @context[:action] = "help"
        @context[:id] = action ? action : @params[:action]
        render_partial 'layouts/context_help'
    end
end
