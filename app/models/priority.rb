# Schema as of Sat Mar 11 16:46:27 AST 2006 (schema version 5)
#
#  id                  :integer(11)   not null
#  name                :string(30)    default(), not null
#  rank                :integer(11)   default(0), not null
#

class Priority < ActiveRecord::Base
    has_many :events
    validates_presence_of :name
    validates_length_of :name, :maximum => 30
    validates_numericality_of :rank, :only_integer => true
    validates_uniqueness_of :rank
end
