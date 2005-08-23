class Event < ActiveRecord::Base
    has_and_belongs_to_many :categories
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
   
    def pending? (group)
        user_ids = []
        for u in group.unauthorized_users
           user_ids << u.id
        end
        group.unauthorized_users.collect{|x| x.id }.include? \
           self.creator.user_id.to_i
    end

    def creator
        User.find( :first, \
            :joins => "LEFT JOIN activities on users.id = user_id " +\
                     "LEFT JOIN events on events.id = event_id",
            :conditions => ["event_id = ? and action = 'CREATE'", self.id]
            )
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
