class AddCoverImageToSubscriptionStorybook < ActiveRecord::Migration
  def change
    add_column :subscription_storybooks, :cover_image, :string
  end
end
