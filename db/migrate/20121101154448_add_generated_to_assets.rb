class AddGeneratedToAssets < ActiveRecord::Migration
  def change
    add_column :assets, :generated, :boolean, default: false
  end
end
