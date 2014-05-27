class AddCoverImageIdToStorybook < ActiveRecord::Migration
  def change
    add_column :storybooks, :cover_image_id, :integer
  end
end
