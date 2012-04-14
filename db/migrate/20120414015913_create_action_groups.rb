class CreateActionGroups < ActiveRecord::Migration
  def change
    create_table :action_groups do |t|
      t.references :action
      t.references :scene

      t.timestamps
    end

    add_index :action_groups, [:action_id, :scene_id], :unique => true
  end
end
