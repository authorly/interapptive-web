class CreateSceneAttributes < ActiveRecord::Migration
  def change
    create_table :scene_attributes do |t|
      t.string :value # TODO: actually a string?
      t.references :keyframe
      t.references :attribute
      t.references :action_group

      t.timestamps
    end
    add_index :scene_attributes, :keyframe_id
    add_index :scene_attributes, :attribute_id
    add_index :scene_attributes, :action_group_id
  end
end
