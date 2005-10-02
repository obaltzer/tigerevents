require "BaseAccountController"
require "LDAPAccountController"
require "SQLAccountController"
class AccountController < ApplicationController
    before_filter :super_user, :only => [:list, :toggle_superuser, \
                                         :toggle_banned]

    def login
        if (AUTH_TYPE == 'ldap')
            @accController = LDAPAccountController.new
        else
            @accController = SQLAccountController.new
        end
        case @request.method
            when :post
                @user = @accController.login_user(@params[:user], @params[:user_password])
                if not @user
                    flash[:auth] = "Login unsuccessful"
                else
                    if @user.banned == 1
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

    def signup
      if request.get?
         @user = User.new
      else
         @user = User.new(params[:user])
	 if @user.save
	    flash[:auth] = "User #{@user.login} created"
	    redirect_to :controller => 'events', :action => 'index'
	 end
       end
    end
    
    def logout
	if not @session[:user]
	    redirect_back_or_default :controller => 'events', :action => 'index'
	end
        @session[:user] = nil
    end

    def list
        if not @params[:search] or @params[:search] == ""
            @params.delete(:search)
            @user_pages, @users = paginate :users, \
                :per_page => 20, \
                :order_by => 'login'
        else
            @user_pages, @users = paginate :users, \
                :per_page => 20, \
                :conditions => ["MATCH(fullname) AGAINST (?) OR login = ?", \
                                @params[:search], @params[:search]], \
                :order_by => 'login'
        end
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
