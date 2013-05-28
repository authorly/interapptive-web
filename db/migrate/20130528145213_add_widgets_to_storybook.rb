class AddWidgetsToStorybook < ActiveRecord::Migration
  def change
    add_column :storybooks, :widgets, :text
  end
end
