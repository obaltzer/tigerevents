class Group < ActiveRecord::Base
    has_many :events
    belongs_to :group_class
    has_and_belongs_to_many :users
    validates_presence_of :name
    validates_uniqueness_of :name
    validates_presence_of :group_class_id
    validates_presence_of :description

    def authorized_users
        return User.find(:all, :include => :groups,
            :conditions => ["authorized = ? AND groups.id = #{self.id}", true])
    end

    def unauthorized_users
        return User.find(:all, :include => :groups,
            :conditions => ["authorized = ? AND groups.id = #{self.id}", false]).collect { |m|
                # this adds the missing authorized attribute to the User
                # object
                m[:authorized] = false
                m
            }
    end

    def undeleted_events
        return Event.find(:all, :include => :group,
            :conditions => ["deleted = ? AND groups.id = #{self.id}", false], 
            :order => "startTime ASC")
    end

    def delete
        self.deleted = true
        self.save
    end
    
end
