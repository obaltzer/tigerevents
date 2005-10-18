module SQLAccountController

    def login_user (user)
        return authenticate(user[:login], user[:user_password])
    end

    def signup
        if request.get?
            @user = User.new
        else
            @user = User.new(params[:user])
            if @user.save
                flash[:auth] = "User #{@user.login} created"
                redirect_to :controller => 'events',
                    :action => 'index'
            end
        end
    end

        private
    def authenticate(username, password)
        hashed_password = User.hash_password(password || "")
        return User.find(:first,
                        :conditions => ["login = ? and hashed_pass = ?",
                        username, hashed_password])
    end
end
