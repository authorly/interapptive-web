class AddWidgetsColumnToKeyframes < ActiveRecord::Migration
  def change
    add_column :keyframes, :widgets, :text
  end
end
