class DestroyTouchZones < ActiveRecord::Migration
  def up
    drop_table :touch_zones
  end

  def down
    create_table :touch_zones do |t|
      t.integer  "scene_id"
      t.integer  "origin_x"
      t.integer  "origin_y"
      t.integer  "radius"
      t.integer  "video_id"
      t.integer  "sound_id"
      t.integer  "action_id"
      t.timestamps
    end

    add_index "touch_zones", ["scene_id"], :name => "index_touch_zones_on_scene_id"
  end
end
