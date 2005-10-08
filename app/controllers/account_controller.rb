require "BaseAccountController"
require "SQLAccountController"
require "LDAPAccountController"
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

    # Authenticates the user against an LDAP server
    #  
    # username: the username of the user
    # password: the user's password with the LDAP server
    #

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
    
    def ldap_authenticate(username, password)
        # initialize return values
        authenticated = false
        fullName = username
        
        # connect to LDAP server
        if (LDAP_USE_SSL)
           conn = LDAP::SSLConn.new( LDAP_URL, LDAP_PORT, LDAP_START_TLS )
        else
           conn = LDAP::Conn.new( LDAP_URL, LDAP_PORT )
        end
       
        begin
            dn = nil
            # query LDAP server for users rdn
            conn.search(LDAP_DN, LDAP::LDAP_SCOPE_SUBTREE, "(uid=#{username})") { |x| 
                if dn
                    raise(RuntimeError, "No distinct user found.")
                end
                dn = x.dn
            }
        rescue RuntimeError
            # if more than one rdn is found, not try to bind
            dn = nil
        end
        
        if dn
            begin
                # bind to LDAP with password
                conn.bind(dn, password)
                # set fullName of user - if the bind fails or there is no display name then
                # fullName remains as the user's login name
                conn.search(LDAP_DN, LDAP::LDAP_SCOPE_SUBTREE, "(uid=#{username})") {|x|
                    if x.vals("displayName")
                        fullName = x.get_values("displayName")[0]
                    end
                }
                # set user as being authenticated
                authenticated = true
            rescue LDAP::ResultError
                # if there is a ResultError, we most likely are not
                # authenticated
                authenticated = false
            end
        end
        return authenticated, fullName
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
