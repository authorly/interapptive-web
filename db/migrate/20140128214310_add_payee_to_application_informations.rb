class AddPayeeToApplicationInformations < ActiveRecord::Migration
  def change
    add_column :application_informations, :payee, :text
  end
end
