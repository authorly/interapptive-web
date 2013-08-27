class AddAllowedStorybooksCountToUsers < ActiveRecord::Migration
  def change
    add_column :users, :allowed_storybooks_count, :integer, :default => 3
  end
end
