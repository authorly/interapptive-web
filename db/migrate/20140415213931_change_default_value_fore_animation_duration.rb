class ChangeDefaultValueForeAnimationDuration < ActiveRecord::Migration
  def up
    change_column :keyframes, :animation_duration, :float, :default => 2.0
  end

  def down
    change_column :keyframes, :animation_duration, :float, :default => 0.3
  end
end
