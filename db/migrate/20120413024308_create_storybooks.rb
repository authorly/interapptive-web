class CreateStorybooks < ActiveRecord::Migration
  def change
    create_table :storybooks do |t|
      t.references :user
      t.string     :title

      t.timestamps
    end
    
    add_index :storybooks, :user_id
  end
end
