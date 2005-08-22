class Group < ActiveRecord::Base
    has_many :events
    has_many :undeleted_events, :class_name => "Event", :conditions => "deleted = 0"
    belongs_to :group_class
    has_and_belongs_to_many :users
    has_and_belongs_to_many :authorized_users, :class_name => "User", :conditions => "authorized = 1"
    has_and_belongs_to_many :unauthorized_users, :class_name => "User", :conditions => "authorized = 0"
    validates_presence_of :name
    validates_uniqueness_of :name
    validates_presence_of :group_class_id
    validates_presence_of :description
end
