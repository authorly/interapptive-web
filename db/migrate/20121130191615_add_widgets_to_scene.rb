class AddWidgetsToScene < ActiveRecord::Migration
  def change
    add_column :scenes, :widgets, :text
  end
end
