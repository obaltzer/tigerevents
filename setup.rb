#!/usr/bin/env ruby
require './config/boot'

begin
    require 'rubygems'
rescue LoadError
    print "You have to have Ruby Gems installed to use this program.\n"
    exit
end

print "\nWelcome to TigerEvents\n"
print "-----------------------\n\n"

print "This setup program will generate a site-specific SQL script\n"
print "which can be used to setup the database as well as perform\n"
print "all site-specific configurations.\n"
print "\nPlease follow the instructions carefully!\n\n"
print "Continue (y/n)? "

cont = gets.strip

if cont != "y"
    print "Bye.\n"
    exit
end


print "Section 1: Server\n"
print "--------------------------------\n"

te_path = nil
while not te_path
    print "\nWhat is the root path to your tigerevents install?\n"
    print "e.g. http://tigerevents.tigeronrails.com\n\n"
    print "Hostname/path: "
    te_path = gets.strip
end

print "Section 2: Authentication System\n"
print "--------------------------------\n"

auth = nil
while not auth
    print "\nWhich authentication system do you want to use to\n"
    print "authenticate user?\n\n"
    print "\t[1] Database\n"
    print "\t[2] LDAP (requires an SSL/TLS enabled LDAP server)\n\n"
    print "Selection (default [1]): "
    auth = gets.strip
    if auth == ""
        auth = "1"
    end
    auth = auth.to_i
    if auth != 1 && auth != 2
        auth = nil
    end
end

# use database authentication
if auth == 1
    print "Database authentication selected.\n\n"
    auth_type = 'SQLAccountController'
elsif auth == 2
    print "LDAP authentication selected.\n\n"
    auth_type = 'LDAPAccountController'
    ldap_ok = false
    while not ldap_ok
        print "Please specify your LDAP server (e.g ldap.foobar.com): "
        ldap_url = gets.strip
        print "Do you want to use encrypted communication (SSL/TLS) with\n"
        print "the LDAP server (y/n)? "
        ldap_use_ssl = gets.strip
        if ldap_use_ssl == "y"
            ldap_use_ssl = "yes"
        else
            ldap_use_ssl = "no"
        end
        if ldap_use_ssl == "yes"
            print "Do you want to use TLS 1.0 instead of SSL (y/n)? "
            ldap_start_tls = gets.strip
            if ldap_start_tls == "y"
                ldap_start_tls = "yes"
            else
                ldap_start_tls = "no"
            end
        end
        print "Please specify your LDAP search base for user\n"
        print "accounts (e.g. dc=foobar,dc=com): "
        ldap_dn = gets.strip

        print "Please specify the field name your LDAP configuration\n"
        print "uses for the user's full name: "
        ldap_displayname = gets.strip

        print "Please specify the field name your LDAP configuration\n"
        print "uses for the user's e-mail address: "
        ldap_email = gets.strip

        print "\nPlease check the following LDAP configuration:\n\n"
        print "\tLDAP server:      #{ldap_url}\n"
        print "\tUse SSL/TLS:      #{ldap_use_ssl}\n"
        if ldap_use_ssl == "yes"
            print "\tUse TLS:          #{ldap_start_tls}\n"
        end
        print "\tLDAP search base: #{ldap_dn}\n"
        print "\tLDAP display name field: #{ldap_displayname}\n"
        print "\tLDAP e-mail field: #{ldap_email}\n"
        print "\nAre those settings correct (y/n)? "
        ldap_ok = gets.strip
        if ldap_ok == "y"
            ldap_ok = true
        else
            ldap_ok = false
        end
    end
end
if not ldap_use_ssl or ldap_use_ssl != "yes"
    ldap_use_ssl = "false"
    ldap_start_tls = "false"
else
    ldap_use_ssl = "true"
    if ldap_start_tls == "yes"
        ldap_start_tls = "true"
    else
        ldap_start_tls = "false"
    end
end
if not ldap_url
    ldap_url = ""
end
if ldap_use_ssl == "true" and ldap_start_tls == "false"
    ldap_port = "636"
else
    ldap_port = "389"
end
if not ldap_dn
    ldap_dn = "dc=search,dc=domain"
end
 
print "Section 2: Administrator Settings\n"
print "---------------------------------\n"

admin_ok = false
while not admin_ok
    print "\nPlease specify the administrators name (e.g. John Doe): "
    admin_name = gets.strip
    print "\nWhat is the administrator's email address\n"
    print "(e.g. john.doe@foobar.com)? "
    admin_email = gets.strip
    if auth_type == "SQLAccountController"
        begin
            require "digest/sha1"
        rescue LoadError
            puts "You need to have the digest/sha1 module installed\n"
            puts "to use SQL authentication."
            puts "Bye."
            exit
        end
        print "\nYou have choosen database authentication.\n"    
        print "What should be the administrator's username (e.g. jdoe)? "
        admin_username = gets.strip
        print "What should be the administrator's password? \033[8m"
        admin_password = gets.strip
#        admin_password = Digest::SHA1.hexdigest(admin_password) 
        print "\033[0m"
    elsif auth_type == "LDAPAccountController"
        print "\nYou have choosen LDAP authentication.\n"
        print "What is the administrators username on the LDAP server? "
        admin_username = gets.strip
    end

    print "Please verify the settings:\n\n"
    print "\tAdministrator's name:         #{admin_name}\n"
    print "\tAdministrator's email addres: #{admin_email}\n"
    print "\tAdministrator's username:     #{admin_username}\n"
    print "\nAre those settings correct (y/n)? "
    admin_ok = gets.strip
    if admin_ok == "y"
        admin_ok = true
    else
        admin_ok = false
    end
end
admin_password ||= ""

print "Section 3: Database Settings\n"
print "----------------------------\n\n"
print "The following are questions about your database connectivity.\n"
print "TigerEvents currently only supports MySQL databases.\n"

db_ok = false
while not db_ok
    print "\nHow should the database server be connected:\n\n"
    print "\t[1] Socket\n"
    print "\t[2] TCP/IP\n"
    print "\nSelection (default [1]): "
    db_conn = gets.strip
    if db_conn == ""
        db_conn = "1"
    end
    db_conn = db_conn.to_i
    if db_conn == 1
        db_conn = "socket"
    elsif db_conn == 2
        db_conn = "TCP/IP"
    end

    if db_conn == "socket"
        print "Please specify the path to the socket to use\n"
        print "(default: /var/run/mysqld/mysqld.sock): "
        db_sock = gets.strip
        if db_sock == ""
            db_sock = "/var/run/mysqld/mysqld.sock"
        end
    elsif db_conn == "TCP/IP"
        print "Please specify the hostname of the database server\n"
        print "(default: localhost): "
        db_host = gets.strip
        if db_host == ""
            db_host = "localhost"
        end
    end

    print "Specify the database that should be used\n"
    print "(default: tigerevents): "
    db_name = gets.strip
    if db_name == ""
        db_name = "tigerevents"
    end
    
    print "Specify the username used to connect to the database\n"
    print "(default: tigerevents): "
    db_user = gets.strip
    if db_user == ""
        db_user = "tigerevents"
    end

    print "Specify the password used for the database user\n"
    print "(default: none): "
    db_pass = gets.strip
    if db_pass == ""
        db_pass = nil
    end
   
    print "Please verify the database connectivity information:\n\n"
    print "\tConnection type: #{db_conn}\n"
    if db_conn == "socket"
        print "\tSocket:          #{db_sock}\n"
    elsif db_conn == "TCP/IP"
        print "\tHostname:        #{db_host}\n"
    end
    print "\tDatabase:            #{db_name}\n"
    print "\tUsername:            #{db_user}\n"
    print "\tPassword:            #{db_pass}\n"
    print "\nAre those informations correct (y/n)? "
    db_ok = gets.strip
    if db_ok == "y"
        db_ok = true
    else
        db_ok = false
    end
end
if db_conn == "socket"
    db_prot = "socket: #{db_sock}"
elsif db_conn == "TCP/IP"
    db_prot = "host: #{db_host}"
end

print "\n\n--------------------------------------------------------------\n"
print "\nThe program is now going to generate 2 files:\n\n"
print "\tconfig/database.yml: contains database connectivity information\n"
print "\t                     for the application\n\n"
print "\tconfig/tigerevents_config: local TigerEvents configuration\n\n"
print "\nExiting files with be saves with extension .orig\n"
print "Continue (y/n)? "
cont = gets.strip

if cont != "y"
    print "Bye.\n"
    exit
end

database = File.join("config", "database.yml")
config = File.join("config", "tigerevents_config.rb")

# write database.yml
if FileTest.exists?(database)
    File.rename(database, database + ".orig")
end
f = File.open(database + ".tmpl", "r")
tmpl = f.read
f.close
x = eval("\"" + tmpl + "\"")
f = File.open(database, "w")
f.write(x)
f.close

# write tigerevents_config.rb
if FileTest.exists?(config)
    File.rename(config, config + ".orig")
end
f = File.open(config + ".tmpl", "r")
tmpl = f.read
f.close
x = eval("\"" + tmpl + "\"")
f = File.open(config, "w")
f.write(x)
f.close

fork do
    exec "rake migrate"
end
Process.wait
if db_conn == "socket"
ActiveRecord::Base.establish_connection(
    :adapter  => "mysql",
    :socket   => "#{db_sock}",
    :username => "#{db_user}",
    :password => "#{db_pass}",
    :database => "#{db_name}"
)
elsif db_conn == "TCP/IP"
ActiveRecord::Base.establish_connection(
    :adapter  => "mysql",
    :host     => "#{db_host}",
    :username => "#{db_user}",
    :password => "#{db_pass}",
    :database => "#{db_name}"
    )
end

User.create(:login => "#{admin_username}",
        :user_password => "#{admin_password}",
        :fullname => "#{admin_name}",
        :superuser => true,
        :email => "#{admin_email}")
ActiveRecord::Base.remove_connection


print "\n\nThe configuration has been written and the database has\n"
print "been set up. You can now run the local test web-server\n"
print "by executing:\n\n"
print "\truby script/server\n\n"
print "and connect to http://localhost:3000/.\n\n"
print "You need to login to the website with the administrator account\n"
print "to setup appropriate group classes before users can start\n"
print "posting events and announcements.\n\n"
