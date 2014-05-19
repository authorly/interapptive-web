class CreateSubscriptionStorybooks < ActiveRecord::Migration
  def change
    create_table :subscription_storybooks do |t|

      t.integer :storybook_id,  :null => false
      t.text    :storybook_json
      t.string  :assets

      t.timestamps
    end

    add_index :subscription_storybooks, :storybook_id
  end
end
