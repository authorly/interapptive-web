class AddNameToAttributes < ActiveRecord::Migration
  def change
    add_column :attributes, :name, :string

  end
end
