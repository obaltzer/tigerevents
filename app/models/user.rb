# Schema as of Sat Mar 11 16:46:27 AST 2006 (schema version 5)
#
#  id                  :integer(11)   not null
#  login               :string(80)    default(), not null
#  fullname            :string(80)    default(), not null
#  hashed_pass         :string(40)    
#  banned              :boolean(1)    not null
#  superuser           :boolean(1)    not null
#  created_on          :datetime      
#  updated_on          :datetime      
#  email               :string(100)   
#  theme               :string(100)   
#

require "digest/sha1"
# This is the model for the user information stored in the database
class User < ActiveRecord::Base
    attr_accessor :user_password
    has_and_belongs_to_many :groups
    has_many :bookmarks
    has_many :layouts
    
    validates_uniqueness_of :login, :on => :create
    validates_presence_of :fullname, :on => :create
    validates_presence_of :user_password, :on => :create
    validates_uniqueness_of :email, :on => :create

    def approved_groups
        return Group.find(:all, :include => :users,
            :conditions => ["authorized = ? AND approved = ? AND users.id =
            #{self.id} AND deleted = ?", true, true, false])
    end

    def unapproved_member
        return Group.find(:all, :include => :users,
            :conditions => ["authorized = ? AND users.id =
            #{self.id} AND deleted = ?", false, false])
    end

    def unapproved_groups
        return Group.find(:all, :include => :users,
            :conditions => ["authorized = ? AND approved = ? AND users.id =
            #{self.id} AND deleted = ?", true, false, false])
    end

    def before_create
        if self.user_password != nil
            self.hashed_pass = User.hash_password(self.user_password)
        end
    end
    
    def after_create
      @password = nil
    end
    
    # Authenticates the user with the given login and password.
    def self.get(user)
        @user = find_first(['login = ?', user[:login]])
    end

    private
    def self.hash_password(password)
      Digest::SHA1.hexdigest(password)
    end
    
end
