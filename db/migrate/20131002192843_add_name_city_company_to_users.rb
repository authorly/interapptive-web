class AddNameCityCompanyToUsers < ActiveRecord::Migration
  def change
    change_table(:users, :bulk => true) do |t|
      t.string :name, :city, :company
    end
  end
end
