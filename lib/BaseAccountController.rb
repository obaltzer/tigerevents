require "ldap" if AUTH_TYPE=="ldap"

class BaseAccountController
    def initialize

    end

    def login_user
        return nil
    end
    
end
