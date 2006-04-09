class RemoveGroupnameIndex < ActiveRecord::Migration
  def self.up
    remove_index :groups, :name
  end

  def self.down
  end
end
