class AccountController < ApplicationController
    before_filter :super_user, :only => [:list, :toggle_superuser, \
                                         :toggle_banned]
    before_filter :login_status, :only => [:login, :signup]

    include eval(AUTH_TYPE)
    
  def login_status
    if !session[:user]
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
      @user = login_user(params[:user])
      if not @user
        flash[:auth] = "Login unsuccessful"
      else
        @user.user_password = nil
        if @user.banned? 
          session[:user] = nil
          flash[:ban_notice] = \
            "You are banned. Please contact <a href='mailto:#{ADMIN_EMAIL}'>#{ADMIN_CONTACT}</a>"
        else
          session[:user] = @user
          if @@available_themes.include?(@user.theme)
            session[:theme] = @user.theme
          else
            session[:theme] = DEFAULT_THEME
          end
        end
      end
      redirect_back_or_default :controller => 'events', :action => 'index'
    end
  end

  def logout
    if not session[:user]
      redirect_back_or_default :controller => 'events', :action => 'index'
    end
    session[:user] = nil
    flash[:auth] = "You have now been successfully logged out"
    redirect_to :action => 'login'
  end

  def list
    if not params[:search] or params[:search] == ""
      params.delete(:search)
      @user_pages, @users = paginate :users, \
         :per_page => 20, \
         :order_by => 'login'
    else
      tokens = params[:search].split.collect {|c| "%#{c.downcase}%"}
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
    render :partial => 'user_list'
  end
 
  def toggle_superuser
    @user = User.find params[:id]
    @user.toggle! :superuser
    redirect_to :action => 'list', \
        :params => { :search => params[:search], :page => params[:page] }
  end
    
  def toggle_banned
    @user = User.find(params[:id])
    @user.toggle! :banned
    # we want to clear the caches after banning/unbanning a user
    SelectorsController.clearCache
    redirect_to :action => 'list', \
        :params => { :search => params[:search], :page => params[:page] }
  end

  def theme
    id = params[:id]
    if id and @@available_themes.include?(id)
      session[:theme] = id
      if session[:user]
        session[:user].theme = id
        session[:user].save
      end
    end
    redirect_back_or_default url_for(:controller => 'event', :action => 'list')
  end

  def AccountController::available_themes
    return @@available_themes
  end
end
