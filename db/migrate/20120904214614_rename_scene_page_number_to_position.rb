class RenameScenePageNumberToPosition < ActiveRecord::Migration
  def change
    rename_column :scenes, :page_number, :position
  end
end
