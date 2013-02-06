class RemoveBackgroundXAndBackgroundYFromKeyframes < ActiveRecord::Migration
  def up
    remove_column :keyframes, :background_x_coord, :background_y_coord
  end

  def down
    add_column :keyframes, :background_x_coord, :integer
    add_column :keyframes, :background_y_coord, :integer
  end
end
