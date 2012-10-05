class AddEnabledToActionDefinition < ActiveRecord::Migration
  def change
    add_column :action_definitions, :enabled, :boolean

  end
end
