class AccountController < ApplicationController
    before_filter :super_user, :only => [:list, :toggle_superuser, \
                                         :toggle_banned]
    before_filter :login_status, :only => [:login, :signup]

    include eval(AUTH_TYPE)

    def login_status
        if !@session[:user]
            return true
        else
            flash[:auth] = "Already Logged in"
            redirect_back_or_default :controller => 'events', :action => 'index'
            return false
        end
    end

    def login
        case @request.method
            when :post
                @user = login_user(@params[:user])
                if not @user
                    flash[:auth] = "Login unsuccessful"
                else
                    @user.user_password = nil
                    if @user.banned? 
                        @session[:user] = nil
                        flash[:ban_notice] = \
                            "You are banned. Please contact" \
                            + "<a href='mailto:" + ADMIN_EMAIL \
                            + "'> " + ADMIN_CONTACT + "</a>"
                    else
                        @session[:user] = @user
                    end
                end
                redirect_to :controller => 'events', :action => 'index'
        end
    end

    def logout
        if not @session[:user]
            redirect_back_or_default :controller => 'events', 
                                     :action => 'index'
        end
        @session[:user] = nil
        flash[:auth] = "You have now been successfully logged out"
        redirect_back_or_default :controller => 'events', :action => 'index'
    end

    def list
        if not @params[:search] or @params[:search] == ""
            @params.delete(:search)
            @user_pages, @users = paginate :users, \
                :per_page => 20, \
                :order_by => 'login'
        else
            tokens = @params[:search].split.collect {|c| "%#{c.downcase}%"}
            @user_pages, @users = paginate :users,
                :per_page => 20,
                :conditions => [(["(LOWER(login) LIKE ? OR LOWER(fullname) LIKE ? )"] * tokens.size).join(" AND "), 
                                *tokens.collect { |token| [token] * 2 }.flatten],
            #                   ^ I have no idea what this star is for, but
            #                   we need it
                :order_by => 'login'
       end
    end

    def live_search
        list
        render_partial 'user_list'
    end
 
    def toggle_superuser
        @user = User.find @params[:id]
        @user.toggle! :superuser
        redirect_to :action => 'list', \
            :params => { :search => @params[:search], \
                :page => @params[:page] }
    end
    
    def toggle_banned
        @user = User.find @params[:id]
        @user.toggle! :banned
        # we want to clear the caches after banning/unbanning a user
        SelectorsController.clearCache
        redirect_to :action => 'list', \
            :params => { :search => @params[:search], \
                :page => @params[:page] }
    end
end
