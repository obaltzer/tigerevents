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
            #{self.id}", true, true])
    end

    def unapproved_member
        return Group.find(:all, :include => :users,
            :conditions => ["authorized = ? AND users.id =
            #{self.id}", false])
    end

    def unapproved_groups
        return Group.find(:all, :include => :users,
            :conditions => ["authorized = ? AND approved = ? AND users.id =
            #{self.id}", true, false])
    end

    def before_create
        if self.user_password != nil
            self.hashed_pass = User.hash_password(self.user_password)
        end
    end
    
    def after_create
      if(self.id > 1)
          AdminMailer.deliver_account_created(self)
      end
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
