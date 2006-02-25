require 'active_support/inflector'

class Selector < ActiveRecord::Base
    ASSOCIATIONS = ["group", "group_class", "priority"]
    ASSOCIATIONS.each { |a| 
        has_and_belongs_to_many Inflector.pluralize(a).intern
    }
    def associations
        ASSOCIATIONS
    end

    validates_presence_of :name
    validates_uniqueness_of :name
end
