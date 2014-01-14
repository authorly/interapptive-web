class AddKissmetricsIdentifierToUsers < ActiveRecord::Migration
  def change
    add_column :users, :kissmetrics_identifier, :string
  end
end
