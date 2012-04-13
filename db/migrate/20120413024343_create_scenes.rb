class CreateScenes < ActiveRecord::Migration
  def change
    create_table :scenes do |t|
      t.references :storybook
      t.references :audio
      t.references :image
      t.integer    :page_number


      t.timestamps
    end

    add_index :scenes, :storybook_id
  end
end
