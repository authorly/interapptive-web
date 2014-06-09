class AddTitleToSubscriptionStorybook < ActiveRecord::Migration
  def change
    add_column :subscription_storybooks, :title, :string
  end
end
