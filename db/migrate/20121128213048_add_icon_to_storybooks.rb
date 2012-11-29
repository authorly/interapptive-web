class AddIconToStorybooks < ActiveRecord::Migration
  def change
    add_column :storybooks, :icon, :string
  end
end
