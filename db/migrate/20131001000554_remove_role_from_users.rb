class RemoveRoleFromUsers < ActiveRecord::Migration
  def up
    remove_column :users, :role
  end

  def down
    add_column :users, :role, :default => 'user', :null => false
  end
end
