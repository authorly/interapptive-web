class AddBackgroundCoordsToScene < ActiveRecord::Migration
  def change
    add_column :scenes, :background_x_coord, :integer
    add_column :scenes, :background_y_coord, :integer
  end
end
