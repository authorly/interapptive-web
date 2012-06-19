class AddBackgroundCoordsToKeyframes < ActiveRecord::Migration
  def change
    add_column :keyframes, :background_x_coord, :integer, :default => 0
    add_column :keyframes, :background_y_coord, :integer, :default => 0
  end
end
