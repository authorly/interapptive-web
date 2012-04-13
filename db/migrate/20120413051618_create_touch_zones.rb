class CreateTouchZones < ActiveRecord::Migration
  def change
    create_table :touch_zones do |t|
      t.references :scene
      t.integer :origin_x
      t.integer :origin_y
      t.integer :radius
      t.references :video
      t.references :audio
      t.timestamps
    end

    add_index :touch_zones, :scene_id
  end
end
