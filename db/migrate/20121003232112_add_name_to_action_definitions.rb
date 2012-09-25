class AddNameToActionDefinitions < ActiveRecord::Migration
  def change
    add_column :action_definitions, :name, :string

  end
end
