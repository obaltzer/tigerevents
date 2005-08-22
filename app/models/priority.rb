class Priority < ActiveRecord::Base
    has_many :events
    validates_presence_of :name
    validates_length_of :name, :maximum => 30
    validates_numericality_of :rank, :only_integer => true
    validates_uniqueness_of :rank
end
