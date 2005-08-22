class Event < ActiveRecord::Base
    has_and_belongs_to_many :categories
    has_and_belongs_to_many :creators, :class_name => "User", :join_table => "activities",
                             :conditions => "action = 'CREATE'"
    belongs_to :group
    belongs_to :priority
    
    # wrapper to properly associate the event with multiple categories
    def categories=(list)
        categories.clear
        categories << Category.find(list)
    end

    def hasEndTime=(val)
        @hasEndTime = val
    end
    
    validate :times
    def times
        if self.announcement == 1
            @hasEndTime = true
        end
        if @hasEndTime and \
                not (self.endTime and self.endTime > self.startTime)
            errors.add "endTime", "has to be after start time"
        end
    end
    
    after_validation :normalizeEndTime
    def normalizeEndTime
        if not @hasEndTime
            self.endTime = nil
        end
        true
    end
    
    after_validation :checkURL
    def checkURL
        if self.url == '' or self.url == 'http://'
            self.url = nil
        end
        true
    end
    
    # validation code
    validates_presence_of :title
    validates_presence_of :description
    validates_presence_of :categories
    validates_presence_of :group
    validates_associated :group
    validates_format_of :url, :with => /^($|https?:\/\/$|https?:\/\/((?:[-a-z0-9]+\.)+[a-z]{2,}))/
end
