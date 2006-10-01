# Be sure to restart your web server when you modify this file.

# Uncomment below to force Rails into production mode when 
# you don't control web/app server and can't set it the proper way
ENV['RAILS_ENV'] ||= 'production'

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence those specified here
  
  # Skip frameworks you're not going to use
  # config.frameworks -= [ :action_web_service, :action_mailer ]

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Force all environments to use the same logger level 
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  # Use the database for sessions instead of the file system
  # (create the session table with 'rake create_sessions_table')
  # config.action_controller.session_store = :active_record_store

  # Enable page/fragment caching by setting a file-based store
  # (remember to create the caching directory and make it readable to the application)
  # config.action_controller.fragment_cache_store = :file_store, "#{RAILS_ROOT}/cache"

  # Use SQL instead of Active Record's schema dumper when creating the test
  # database.
  # This is necessary if your schema can't be completely dumped by the schema dumper,
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector

  # Make Active Record use UTC-base instead of local time
  # config.active_record.default_timezone = :utc
  
  # Use Active Record's schema dumper instead of SQL when creating the test database
  # (enables use of different database adapters for development and test environments)
  # config.active_record.schema_format = :ruby

  # See Rails::Configuration for more options
end

# Add new inflection rules using the following format 
# (all these examples are active by default):
# Inflector.inflections do |inflect|
#   inflect.plural /^(ox)$/i, '\1en'
#   inflect.singular /^(ox)en/i, '\1'
#   inflect.irregular 'person', 'people'
#   inflect.uncountable %w( fish sheep )
# end

# Include your application configuration below

ActiveSupport::CoreExtensions::Time::Conversions::DATE_FORMATS.merge!(
  :short_detailed_format => '%a %b %d %I:%M %p',
  :human_expanded_format => '%A, %B %d %Y - %I:%M %p',
  :short_detailed_format_24h => '%a %b %d %H:%M',
  :human_expanded_format_24h => '%A, %B %d %Y - %H:%M',
  :human_short_format => '%A, %b %d %Y',
  :hour_format => '%I:%M %p',
  :hcard_format => '%Y-%m-%dTO%H:%M:%S-04:00',
  :iCal_short => '%Y%m%dT%H%M%SZ'
)

module ActiveSupport::CoreExtensions::Time::Conversions
    def to_ordinalized_s(format = :default)
        format = ActiveSupport::CoreExtensions::Time::Conversions::DATE_FORMATS[format]
        return to_default_s if format.nil?
        strftime(format.gsub(/%d/, '_%d_')).gsub(/_(\d+)_/) { |s| s.to_i.ordinalize }
    end
end

require_gem 'acts_as_taggable'
require 'tigerevents_config'

@@available_themes = []
Dir.foreach('./themes/') do |file|
    if File.basename(file)[0] != ?.
         @@available_themes << file
    end
end
