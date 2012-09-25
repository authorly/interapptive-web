class AddActionToTouchZone < ActiveRecord::Migration
  def change
    add_column :touch_zones, :action_id, :integer
  end
end
