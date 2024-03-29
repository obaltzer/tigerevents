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
                redirect_to events_url
                if(@user.id > 1)
                    AdminMailer.deliver_account_created(@user)
                end
            end
        end
    end

    def change_pass
        if request.get?
        else
            user = User.find(:first, :conditions => ["id= ?", session[:user].id])
            if session[:user].hashed_password = User.hash_password(params[:password][:oldpassword]) 
                if params[:password][:newpassword] == params[:password][:verifypassword]
                    user.hashed_password = User.hash_password(params[:password][:newpassword])
                    user.save
                    flash[:auth]="Password Successfully changes"
                    redirect_to events_url
                    return true
                end
                flash[:auth] = "Password Verification Fails"
                redirect_to events_url
            else
                flash[:auth] = "Old Password Entered Incorrectly"
                redirect_to events_url
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
