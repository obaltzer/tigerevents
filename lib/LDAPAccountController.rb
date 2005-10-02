require "ldap" if AUTH_TYPE=="ldap"

class LDAPAccountController < BaseAccountController

    def initialize
        super
    end

    def authenticate(username, password)
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
		    #set user as being authenticated
                    authenticated = true
                }
            rescue LDAP::ResultError
                # if there is a ResultError, we most likely are not
                # authenticated
                authenticated = false
	    end
	end
	return authenticated, fullName
    end

    def login_user (user, pass)
        @authenticated, fullname = authenticate(user[:login], pass)
        if @authenticated
            user.update("fullname" => fullname)
            @user = User.get(user)
            if not @user
                @user = User.new(user)
                @user.save
            end
            if @user.fullname != fullname
                @user.update_attribute(:fullname, fullname)
            end
            return @user
        else
            return nil
        end
    end
end
