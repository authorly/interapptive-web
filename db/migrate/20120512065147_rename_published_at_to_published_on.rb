class RenamePublishedAtToPublishedOn < ActiveRecord::Migration
  def change
    rename_column :storybooks, :published_at, :published_on
  end
end
