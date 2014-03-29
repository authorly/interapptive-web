class AddResourceArchiveToStorybooks < ActiveRecord::Migration
  def change
    add_column :storybooks, :resource_archive, :string
  end
end
