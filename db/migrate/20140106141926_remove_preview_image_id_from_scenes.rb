class RemovePreviewImageIdFromScenes < ActiveRecord::Migration
  def up
    remove_column :scenes, :preview_image_id
  end

  def down
    add_column :scenes, :preview_image_id, :integer
  end
end
