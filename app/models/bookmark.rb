# Schema as of Sat Mar 11 16:46:27 AST 2006 (schema version 5)
#
#  id                  :integer(11)   not null
#  user_id             :integer(11)   default(0), not null
#  event_id            :integer(11)   default(0), not null
#

class Bookmark <  ActiveRecord::Base
    belongs_to :user
    has_one :event
end
