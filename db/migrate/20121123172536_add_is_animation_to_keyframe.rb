class AddIsAnimationToKeyframe < ActiveRecord::Migration
  def change
    add_column :keyframes, :is_animation, :boolean, default: false
  end
end
