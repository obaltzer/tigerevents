# TigerEvents Version String
TE_VERSION = 'svn/trunk'

#LDAP settings
LDAP_USE_SSL = true
LDAP_URL = 'ldap.foobar.com'
LDAP_PORT = 389
LDAP_DN = 'dc=search,dc=domain'
LDAP_START_TLS = true 

# selector cache settings
# expiry time in seconds
EXPIRY_TIME = 300

ADMIN_CONTACT = 'TigerEvents Administrator'
ADMIN_EMAIL = 'tigerevents@localhost'

MAIL_SUFFIX = '@localhost'

# AUTH_TYPE defines where users authenticate from.
# ldap - an ldap server defined by the ldap settings
# mysql - an sql server
AUTH_TYPE = 'ldap'

# This variable holds the relative or absolute URL through which
# authentication should be passes. Set this to the address of the 'login'
# action in the 'account' controller on your preferably secure server, e.g.
# 'https://www.foobar.com/account/login'. If you do not have a separate
# secure server or your complete site is served through a secure server you
# can leave this value untouched.
LOGIN_URL = '/account/login'
