if LIBLDAP then
  require 'ldap'
else
  require 'net/ldap'
end

module LDAPAccountController

  def new 
  end

  def login_user (user)
    @authenticated, fullname, email, entry =
      authenticate(user[:login], user[:user_password])
    if @authenticated
      @user = User.find_or_create_by_login(user[:login])
      @user.save
      @user.update_attribute(:fullname, fullname) if @user.fullname != fullname
      @user.update_attribute(:email, email) if @user.email != email
      @user.instance_variable_set(:@ldap_entry,entry)
      return @user
    else
      return nil
    end
  end

private

  def authenticate(username, password)
    if LIBLDAP then
      return authenticate_libldap(username,password)
    else
      return authenticate_netldap(username,password)
    end
  end

  def authenticate_libldap(username, password)
    # initialize return values
    authenticated = false
    fullName = username
    email = username
    entry = nil

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
          entry = x.to_hash
          if x.vals(LDAP_DISPLAY_NAME)
            fullName = x.get_values(LDAP_DISPLAY_NAME)[0]
          end
          if x.vals(LDAP_EMAIL_ADDRESS)
            email = x.get_values(LDAP_EMAIL_ADDRESS)[0]
          end
          #set user as being authenticated
          authenticated = true
        }
      rescue LDAP::ResultError
        # if there is a ResultError, we most likely are not
        # authenticated
        authenticated = false
      end
    end
    return [authenticated, fullName, email, entry]
  end

  def authenticate_netldap(username, password)
    auth = false
    fn = username
    em = username

    ldap_options = {}
    ldap_options[:host] = LDAP_URL
    ldap_options[:port] = LDAP_PORT
    ldap_options[:encryption] = { :method => :simple_tls } if LDAP_USE_SSL

    # Find the LDAP dn associated with the login.
    filter = Net::LDAP::Filter.eq( "uid", username )
    search_options = { :base => LDAP_DN, :filter => filter,
                :return_result => true }
    ldap = Net::LDAP.new(ldap_options)
    r = ldap.search(search_options)
    return [auth,fn,em] unless r and r.size == 1
    r = r.first

    # If we found the distinguished name, log in with it, and get
    # our user
    ldap_options[:auth] = { :method => :simple,
            :username => r.dn, :password => password }
    ldap = Net::LDAP.new(ldap_options)
    r = ldap.search(search_options)
    return [auth,fn,em] unless r and r.size == 1
		
    # Be sure to get the ldap entry in a hash form, which is serializable
    # (the basic object is not, as it contains Singletons and Proc objects)
    r = r.first.to_hash

    auth = true
    fn = r[LDAP_DISPLAY_NAME].first if r[LDAP_DISPLAY_NAME]
    em = r[LDAP_EMAIL_ADDRESS].first if r[LDAP_EMAIL_ADDRESS]

    return [auth, fn, em, r]
  end
end
