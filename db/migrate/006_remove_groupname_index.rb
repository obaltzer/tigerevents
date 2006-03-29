class RemoveGroupnameIndex < ActiveRecord::Migration
  def self.up
    remove_index :groups, :name
  end

  def self.down
    add_index :groups, [:name], :unique => true
  end
end
