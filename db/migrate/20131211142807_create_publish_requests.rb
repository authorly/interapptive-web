class CreatePublishRequests < ActiveRecord::Migration
  def change
    create_table :publish_requests do |t|
      t.integer :storybook_id
      t.integer :applications_count, default: 0
      t.timestamps
    end
  end
end
