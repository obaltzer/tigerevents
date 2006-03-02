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
