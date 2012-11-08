class RenameImageIdToPreviewImageIdInKeyframe < ActiveRecord::Migration
  def change
    rename_column :keyframes, :image_id, :preview_image_id
  end
end
