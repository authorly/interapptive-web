class AddAssetTypeToAssets < ActiveRecord::Migration
  def change
    add_column :assets, :asset_type, :string, :default => 'custom'
  end
end
