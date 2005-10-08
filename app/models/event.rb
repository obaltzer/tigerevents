require 'date'
class Event < ActiveRecord::Base
    has_and_belongs_to_many :categories
    belongs_to :group
    belongs_to :priority
    attr_writer :hasEndTime
    
    # wrapper to properly associate the event with multiple categories
    def categories=(list)
        categories.clear
        categories << Category.find(list)
    end

    def isEditableBy(user)
        if (user == nil)
            return false
        elsif (user.approved_groups.include? Group.find(self.group_id))
            return true
        end
        return false
    end

    before_validation :convert_times
    def convert_times
        begin
            self.startTime = convert_time @start_date, @start_hour,\
                                            @start_min, @start_ampm
        rescue ArgumentError
            self.startTime = nil
            errors.add "startTime", "is invalid"
        end
        begin
            self.endTime = convert_time @end_date, @end_hour,\
                                            @end_min, @end_ampm
        rescue ArgumentError
            self.endTime = nil
            if @hasEndTime
                errors.add "endTime", "is invalid"
            end
        end
    end
    
    def pending? (group)
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
   
    def lastEditted
        User.find( :first, \
            :joins => "LEFT JOIN activities on users.id = user_id " +\
                     "LEFT JOIN events on events.id = event_id",
            :conditions => ["event_id = ?", self.id],
            :order => "activities.updated_on DESC"
            )
    end

    def expired?
        self.startTime < Time.now and (not self.endTime or self.endTime < \
             Time.now )
    end

    validate :times
    def times
        #checking that the event is scheduled for a future time
        if (self.startTime and self.startTime < Time.now and ( not @hasEndTime or \
            not self.endTime or self.endTime < Time.now ) )
           errors.add_to_base "You can not schedule events for dates that have" +\
                      " already passed"
        end
        
        if self.announcement == 1
            @hasEndTime = true
        end
        #checking that endtime is after starttime
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
    
    def start_date=(date_str)
        begin
            a = date_str.split(/\//).collect {|x| x.to_i}
            @start_date = Date.new a[2], a[1], a[0]
        rescue ArgumentError
            @start_date = nil
        end
    end

    def start_date
        self.startTime ? self.startTime.strftime("%d/%m/%Y") : "dd/mm/yyyy"
    end
   
    def start_min=(min)
        @start_min = min.to_i
    end
    
    def start_hour=(hour)
        @start_hour = hour.to_i
    end
    
    def start_ampm=(ampm)
        @start_ampm = (ampm.to_i == 1 ? true : false)
    end
        
    def start_hour
        if not self.startTime or self.startTime.hour == 0
            12
        elsif self.startTime.hour > 12
            self.startTime.hour - 12
        else
            self.startTime.hour
        end
    end
            
    def start_min
        self.startTime ? self.startTime.min : 0
    end

    def start_ampm
        not self.startTime or self.startTime.hour >= 12 ? true : false
    end
    
    def end_date=(date_str)
        begin
            a = date_str.split(/\//).collect {|x| x.to_i}
            @end_date = Date.new a[2], a[1], a[0]
        rescue ArgumentError
            @end_date = nil
        end
    end

    def end_date
        self.endTime ? self.endTime.strftime("%d/%m/%Y") : "dd/mm/yyyy"
    end
   
    def end_min=(min)
        @end_min = min.to_i
    end
    
    def end_hour=(hour)
        @end_hour = hour.to_i
    end
    
    def end_ampm=(ampm)
        @end_ampm = (ampm.to_i == 1 ? true : false)
    end
        
    def end_hour
        if not self.endTime or self.endTime.hour == 0
            12
        elsif self.endTime.hour > 12
            self.endTime.hour - 12
        else
            self.endTime.hour
        end
    end
            
    def end_min
        self.endTime ? self.endTime.min : 0
    end

    def end_ampm
        not self.endTime or self.endTime.hour >= 12 ? true : false
    end
    
    # validation code
    validates_presence_of :title
    validates_presence_of :startTime
    validates_presence_of :description
    validates_presence_of :categories
    validates_presence_of :group
    validates_associated :group
    validates_format_of :url, :with => /^($|https?:\/\/$|https?:\/\/((?:[-a-z0-9]+\.)+[a-z]{2,}))/

    private
        def convert_time date, hour, min, ampm
            if not date
                raise ArgumentError, "Date cannot be nil."
            end

            h = hour
            if ampm
                h = h == 12 ? h : h + 12
            else
                h = h == 12 ? 0 : h
            end
            Time.mktime date.year, date.month, date.day, h, min, 0, 0
        end
end
