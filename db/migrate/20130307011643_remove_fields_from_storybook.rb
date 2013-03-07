class RemoveFieldsFromStorybook < ActiveRecord::Migration
  def up
    remove_column :storybooks, :android_or_ios
    remove_column :storybooks, :record_enabled
    remove_column :storybooks, :publisher
    remove_column :storybooks, :published_on
    remove_column :storybooks, :tablet_or_phone
  end

  def down
    add_column :storybooks, :android_or_ios, :string
    add_column :storybooks, :record_enabled, :boolean
    add_column :storybooks, :publisher, :string
    add_column :storybooks, :published_on, :date
    add_column :storybooks, :tablet_or_phone, :boolean
  end
end
