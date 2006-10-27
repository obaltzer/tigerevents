# Schema as of Sat Mar 11 16:46:27 AST 2006 (schema version 5)
#
#  id                  :integer(11)   not null
#  name                :string(100)   default(), not null
#  description         :text          default(), not null
#  group_class_id      :integer(11)   
#  approved            :boolean(1)    not null
#  deleted             :boolean(1)    not null
#

class Group < ActiveRecord::Base
    has_many :events
    belongs_to :group_class
    has_and_belongs_to_many :users
    validates_presence_of :name
    validates_uniqueness_of :name, :if => Proc.new {determine_uniqueness(:name)}
    validates_presence_of :group_class_id
    validates_presence_of :description

    def self.determine_uniqueness(name)
        @group = Group.find(:first, :conditions => ["name = ? and deleted = ?", name, false])
        if(@group == nil) 
            return false
        end
        return true
    end

    def authorized_users
      return User.find(:all, 
        :include => :groups,
        :conditions => ["authorized = ? AND groups.id = #{self.id}", true])
    end

    def unauthorized_users
        return User.find(:all, 
          :include => :groups,
          :conditions => ["authorized = ? AND groups.id = #{self.id}", false]).collect { |m|
            # this adds the missing authorized attribute to the User
            # object
            m[:authorized] = false
            m
          }
    end

    def undeleted_events
        return Event.find(:all, :include => :group,
            :conditions => ["events.deleted = ? AND groups.id = #{self.id}", false], 
            :order => "startTime ASC")
    end

  def delete
    #no events means a bad group
    if self.events.first == nil
      #remove associations and delete
      for user in self.users
        self.users.delete(user)
      end
      self.destroy
    else
      #otherwise just flag in the database
      self.deleted = true
      self.save
    end
  end
end
