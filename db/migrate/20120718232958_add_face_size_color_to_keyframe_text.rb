class AddFaceSizeColorToKeyframeText < ActiveRecord::Migration
  def change
    add_column :keyframe_texts, :face, :string
    add_column :keyframe_texts, :size, :integer
    add_column :keyframe_texts, :color, :string
  end
end
