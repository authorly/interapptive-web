class ChangeKeyframeContentHighlightTimesFromStringToText < ActiveRecord::Migration
  def up
    change_column :keyframes, :content_highlight_times, :text
  end

  def down
    change_column :keyframes, :content_highlight_times, :string
  end
end
