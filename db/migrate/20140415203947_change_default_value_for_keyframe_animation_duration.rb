class ChangeDefaultValueForKeyframeAnimationDuration < ActiveRecord::Migration
  def up
    change_column :keyframes, :animation_duration, :float, :default => 0.3
  end

  def down
    change_column :keyframes, :animation_duration, :float, :default => 3.0
  end
end
