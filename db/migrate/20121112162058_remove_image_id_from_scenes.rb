class RemoveImageIdFromScenes < ActiveRecord::Migration
  def up
    remove_column :scenes, :image_id
  end

  def down
    add_column :scenes, :image_id, :integer
  end
end
