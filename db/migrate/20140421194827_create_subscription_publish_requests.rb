class CreateSubscriptionPublishRequests < ActiveRecord::Migration
  def change
    create_table :subscription_publish_requests do |t|

      t.integer :storybook_id,              :null => false
      t.integer :subscription_storybook_id
      t.string  :status,                    :null => false, :default => 'review-required'
      t.timestamps
    end

    add_index :subscription_publish_requests, :storybook_id
    add_index :subscription_publish_requests, :subscription_storybook_id
  end
end
