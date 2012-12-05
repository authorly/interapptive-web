class MoveContentHighlightTimesToKeyframe < ActiveRecord::Migration
  def change
    remove_column :keyframe_texts, :content_highlight_times
    add_column :keyframes, :content_highlight_times, :string
  end
end
