# This is the model for the user information stored in the database
class User < ActiveRecord::Base
    has_and_belongs_to_many :groups
    has_and_belongs_to_many :approved_groups, :class_name => "Group", :conditions => "authorized = 1 AND approved=1"
    has_and_belongs_to_many :unapproved_member, :class_name => "Group", :conditions => "authorized = 0"
    has_and_belongs_to_many :unapproved_groups, :class_name => "Group", :conditions => "authorized = 1 AND approved=0"
    has_many :bookmarks
    has_many :layouts, :order => "rank"
    
    validates_uniqueness_of :login, :on => :create
   
    # Authenticates the user with the given login and password.
    def self.get(user)
        @user = find_first(['login = ?', user[:login]])
    end

end
