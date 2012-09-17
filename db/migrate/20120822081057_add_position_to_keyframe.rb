class AddPositionToKeyframe < ActiveRecord::Migration
  def change
    add_column :keyframes, :position, :integer
  end
end
