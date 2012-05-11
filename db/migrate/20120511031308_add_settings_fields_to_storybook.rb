class AddSettingsFieldsToStorybook < ActiveRecord::Migration
  def change
    add_column :storybooks, :author, :string
    add_column :storybooks, :description, :text
    add_column :storybooks, :publisher, :string
    add_column :storybooks, :published_at, :date
    add_column :storybooks, :price, :decimal, :precision => 8, :scale => 2
    add_column :storybooks, :build_ios, :boolean, :default => true
    add_column :storybooks, :build_android, :boolean, :default => true
    add_column :storybooks, :build_tablet, :boolean, :default => true
    add_column :storybooks, :build_phone, :boolean, :default => true
    add_column :storybooks, :record_enabled, :string
  end
end
