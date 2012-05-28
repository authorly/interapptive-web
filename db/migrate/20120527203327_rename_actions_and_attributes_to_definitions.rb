class RenameActionsAndAttributesToDefinitions < ActiveRecord::Migration
  def up
    rename_table :actions, :action_definitions
    rename_table :attributes, :attribute_definitions

    rename_column :attribute_definitions, :action_id, :action_definition_id

    create_table :actions do |t|
      t.references :scene
      t.references :action_definition
    end

    add_index :actions, :scene_id
    add_index :actions, :action_definition_id

    create_table :attributes do |t|
      t.references :attribute_definition
      t.references :keyframe
      t.string     :value
    end

    add_index :attributes, :attribute_definition_id
    add_index :attributes, :keyframe_id

    drop_table :action_groups
  end

  def down
    create_table :action_groups do |t|
      t.references :action
      t.references :scene
    end

    drop_table :attributes
    drop_table :actions

    rename_column :attribute_definitions, :action_definition_id, :action_id

    rename_table :attribute_definitions, :attributes
    rename_table :action_definitions, :actions
  end
end
