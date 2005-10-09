require "BaseAccountController"
class SQLAccountController < BaseAccountController

    def initialize
        super
    end

    def login_user (user)
        return authenticate(user[:login], user[:user_password])
    end

    def signup
        return true
    end
    
    private
    def authenticate(username, password)
        hashed_password = User.hash_password(password || "")
        return User.find(:first,
            :conditions => ["login = ? and hashed_pass = ?",
                username, hashed_password])
    end


end
