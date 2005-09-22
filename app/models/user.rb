require "digest/sha1"
# This is the model for the user information stored in the database
class User < ActiveRecord::Base
    attr_accessor :user_password
    has_and_belongs_to_many :groups
    has_and_belongs_to_many :approved_groups, :class_name => "Group", :conditions => "authorized = 1 AND approved=1"
    has_and_belongs_to_many :unapproved_member, :class_name => "Group", :conditions => "authorized = 0"
    has_and_belongs_to_many :unapproved_groups, :class_name => "Group", :conditions => "authorized = 1 AND approved=0"
    has_many :bookmarks
    has_many :layouts, :order => "rank"
    
    validates_uniqueness_of :login, :on => :create

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
