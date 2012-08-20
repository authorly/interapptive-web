class AddActionIdToAttribute < ActiveRecord::Migration
  def change
    change_table :attribute_definitions do |t|
      t.references :action
    end

    change_table :action_definitions do |t|
      t.remove :name
    end
  end
end
