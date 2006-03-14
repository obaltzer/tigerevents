# Schema as of Sat Mar 11 16:46:27 AST 2006 (schema version 5)
#
#  id                  :integer(11)   not null
#  user_id             :integer(11)   
#

class Layout < ActiveRecord::Base
    belongs_to :user
    has_and_belongs_to_many :selectors, :order => "rank"
end
