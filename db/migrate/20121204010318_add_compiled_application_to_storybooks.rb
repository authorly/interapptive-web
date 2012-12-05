class AddCompiledApplicationToStorybooks < ActiveRecord::Migration
  def change
    add_column :storybooks, :compiled_application, :string
  end
end
