class GroupDeleted < ActiveRecord::Migration
  def self.up
    add_column :groups, :deleted, :boolean, :default => false, 
               :null => true 
    Group.update_all ["deleted = ?", false], "deleted IS NULL"
    change_column :groups, :deleted, :boolean, :default => false, 
                  :null => false
  end

  def self.down
    remove_column :groups, :deleted
  end
end
