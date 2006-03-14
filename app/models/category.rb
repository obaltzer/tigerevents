# Schema as of Sat Mar 11 16:46:27 AST 2006 (schema version 5)
#
#  id                  :integer(11)   not null
#  name                :string(100)   default(), not null
#  hide                :boolean(1)    not null
#  created_on          :datetime      
#  updated_on          :datetime      
#  created_by          :integer(11)   default(0), not null
#

class Category < ActiveRecord::Base
    has_and_belongs_to_many :events
    validates_presence_of :name
    validates_uniqueness_of :name

    def self.category_objects(category_names)
      @categories = Array.new
      for tag in category_names
        @categories << Category.find(:first, :conditions => ["name = ?", tag])
      end
      return @categories
    end

    def self.category_item(category)
      Category.find(:first, :conditions =>["name=?", category])
    end
    
end
