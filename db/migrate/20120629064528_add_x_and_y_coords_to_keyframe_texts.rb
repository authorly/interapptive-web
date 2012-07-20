class AddXAndYCoordsToKeyframeTexts < ActiveRecord::Migration
  def change
    add_column :keyframe_texts, :x_coord, :integer, :default => 0

    add_column :keyframe_texts, :y_coord, :integer, :default => 0

  end
end
