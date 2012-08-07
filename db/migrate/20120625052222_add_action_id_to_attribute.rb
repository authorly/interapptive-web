class AddActionIdToAttribute < ActiveRecord::Migration
  def change
    change_table :attributes do |t|
      t.references :action
    end

    change_table :actions do |t|
      # t.remove :name
    end
  end
end
