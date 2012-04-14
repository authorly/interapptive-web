class CreateAttributes < ActiveRecord::Migration
  def change
    create_table :attributes do |t|
      t.references :action
      t.string :type

      t.timestamps
    end
    add_index :attributes, :action_id
  end
end
