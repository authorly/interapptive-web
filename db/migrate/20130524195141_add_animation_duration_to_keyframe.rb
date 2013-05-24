class AddAnimationDurationToKeyframe < ActiveRecord::Migration
  def change
    add_column :keyframes, :animation_duration, :float, default: 3
  end
end
