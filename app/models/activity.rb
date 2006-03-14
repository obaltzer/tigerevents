# Schema as of Sat Mar 11 16:46:27 AST 2006 (schema version 5)
#
#  id                  :integer(11)   not null
#  action              :string(100)   default(), not null
#  user_id             :integer(11)   default(0), not null
#  event_id            :integer(11)   default(0), not null
#  created_on          :datetime      
#  updated_on          :datetime      
#

class Activity < ActiveRecord::Base
    belongs_to :event
    belongs_to :user
end
