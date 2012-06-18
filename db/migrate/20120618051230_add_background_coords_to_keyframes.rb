class AddBackgroundCoordsToKeyframes < ActiveRecord::Migration
  def change
    add_column :keyframes, :background_x_coord, :integer
    add_column :keyframes, :background_y_coord, :integer
  end
end
