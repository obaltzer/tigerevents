class UserTheme < ActiveRecord::Migration
  def self.up
    add_column :users, :theme, :string, :limit => 100
  end

  def self.down
    remove_column :users, :theme
  end
end
