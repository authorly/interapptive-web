class AddConfirmationTokenAndConfirmedToUsers < ActiveRecord::Migration
  def change
    add_column :users, :confirmation_token, :string
    add_column :users, :confirmed,          :boolean, :default => false
  end
end
