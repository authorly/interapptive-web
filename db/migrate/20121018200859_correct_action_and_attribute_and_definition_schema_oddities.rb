class CorrectActionAndAttributeAndDefinitionSchemaOddities < ActiveRecord::Migration
  def up
    # Some schema oddities:
    # 1. Rename old index whose column was renamed.
    remove_index :attribute_definitions, :name => "index_attributes_on_action_id"
    add_index :attribute_definitions, :action_definition_id
    # 2. Remove unnecessary reference column
    remove_column :attribute_definitions, :action_id

    # 3. Remove unnecessary reference column and index
    remove_index :attributes, :keyframe_id
    remove_column :attributes, :keyframe_id

    # 4. Add necessary reference column and index
    add_column :attributes, :action_id, :integer
    add_index :attributes, :action_id
  end

  def down
    remove_index :attributes, :action_id
    remove_column :attributes, :action_id

    add_column :attributes, :keyframe_id, :integer
    add_index :attributes, :keyframe_id

    add_column :attribute_definitions, :action_id, :integer

    # This is not idempotent, exactly, but that's okay
    # since the current version is out of whack.
    # We're not going to roll it back because this should have been
    # changed when the column was renamed.
    # rename_index :attribute_definitions, :action_definition_id, :action_id
  end
end
