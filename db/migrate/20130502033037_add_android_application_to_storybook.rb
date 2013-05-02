class AddAndroidApplicationToStorybook < ActiveRecord::Migration
  def change
    add_column :storybooks, :android_application, :string
  end
end
