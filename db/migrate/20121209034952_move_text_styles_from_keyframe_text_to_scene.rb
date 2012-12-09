class MoveTextStylesFromKeyframeTextToScene < ActiveRecord::Migration
  def up
    remove_column :keyframe_texts, :face
    remove_column :keyframe_texts, :size
    remove_column :keyframe_texts, :color
    remove_column :keyframe_texts, :weight
    remove_column :keyframe_texts, :align

    add_column :scenes, :font_face, :string, :default => 'Arial'
    add_column :scenes, :font_size, :string, :default => '25'
    add_column :scenes, :font_color, :string, :default => 'rgb(255, 0, 0)'
  end

  def down
    add_column :keyframe_texts, :face, :string, :default => 'Arial'
    add_column :keyframe_texts, :size, :string, :default => '25'
    add_column :keyframe_texts, :color, :string, :default => 'rgb(255, 0, 0)'
    add_column :keyframe_texts, :weight, :string, :default => 'normal'
    add_column :keyframe_texts, :align, :string, :default => 'left'

    remove_column :scenes, :font_face
    remove_column :scenes, :font_size
    remove_column :scenes, :font_color
  end
end
