class RemovePreviewIds < ActiveRecord::Migration
  def up
    Keyframe.update_all(preview_image_id: nil)
    Scene.update_all(preview_image_id: nil)
  end

  def down
  end
end
