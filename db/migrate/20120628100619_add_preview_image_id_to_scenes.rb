class AddPreviewImageIdToScenes < ActiveRecord::Migration
  def change
    add_column :scenes, :preview_image_id, :integer
  end
end
