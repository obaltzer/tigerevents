class GroupClass < ActiveRecord::Base
    has_many :groups
    validates_presence_of :name
    validates_uniqueness_of :name
end
