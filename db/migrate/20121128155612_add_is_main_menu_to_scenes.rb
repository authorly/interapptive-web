class AddIsMainMenuToScenes < ActiveRecord::Migration
  def change
    add_column :scenes, :is_main_menu, :boolean, default: false
  end
end
