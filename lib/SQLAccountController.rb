require "BaseAccountController"
class SQLAccountController < BaseAccountController

    def initialize
        super
    end

    def login_user (user, pass)
        return authenticate(user[:login], pass)
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
