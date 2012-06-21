class AddPreviewImageToKeyframe < ActiveRecord::Migration
  change_table :keyframes do |t|
    t.integer :image_id
  end
end
