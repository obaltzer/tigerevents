$KCODE = 'u'
require 'jcode'

# TigerEvents Version String
TE_VERSION = 'svn/trunk'

# selector cache settings
# expiry time in seconds
EXPIRY_TIME = 300

# Administrator Contact Information
ADMIN_CONTACT = 'TigerEvents Administrator'
ADMIN_EMAIL = 'tigerevents@localhost'

# AUTH_TYPE defines where users authenticate from.
# ldap - an ldap server defined by the ldap settings
# sql - an sql server
AUTH_TYPE = 'SQLAccountController'

#LDAP settings
LDAP_USE_SSL = true
LDAP_URL = 'ldap.dal.ca'
LDAP_PORT = 389
LDAP_DN = 'dc=dal,dc=ca'
LDAP_START_TLS = true 
#LDAP entry mappings
#LDAP_DISPLAY_NAME is the full name of the individual
LDAP_DISPLAY_NAME = 'displayName'
LDAP_EMAIL_ADDRESS = 'mail'

# This variable holds the relative or absolute URL through which
# authentication should be passes. Set this to the address of the 'login'
# action in the 'account' controller on your preferably secure server, e.g.
# 'https://www.foobar.com/account/login'. If you do not have a separate
# secure server or your complete site is served through a secure server you
# can leave this value untouched.
LOGIN_URL = '/account/login'
