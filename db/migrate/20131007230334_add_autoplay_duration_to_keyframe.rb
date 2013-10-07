class AddAutoplayDurationToKeyframe < ActiveRecord::Migration
  def change
    add_column :keyframes, :autoplay_duration, :float
  end
end
