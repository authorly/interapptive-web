class CreateSettings < ActiveRecord::Migration
  def change
    create_table :settings do |t|
      t.string     :type
      t.references :scene
      t.references :storybook
      t.references :font
      t.integer :font_size

      t.timestamps
    end
    
    add_index :settings, :scene_id
    add_index :settings, :storybook_id
  end
end
