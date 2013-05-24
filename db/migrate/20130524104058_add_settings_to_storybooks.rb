class AddSettingsToStorybooks < ActiveRecord::Migration
  def change
    add_column :storybooks, :settings, :text
  end
end
