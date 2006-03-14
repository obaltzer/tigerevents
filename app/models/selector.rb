# Schema as of Sat Mar 11 16:46:27 AST 2006 (schema version 5)
#
#  id                  :integer(11)   not null
#  name                :string(100)   default(), not null
#  label               :string(100)   default(), not null
#  include_events      :boolean(1)    not null
#  include_announcement:boolean(1)    not null
#

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
